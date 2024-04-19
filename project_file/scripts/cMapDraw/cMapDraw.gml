function cMapDraw() class {
    #region Private
    /* 
       renderer <- 3D Model Display
       renderProperties <- The properties that the map will be drawn with
    */
    __renderer = new c3dModelRenderer();
    __renderProperties = new cRenderProperties();
    __mapModel = new c3dModel()
    .SetName( "map" )
    .SetModel( CACHE_PATH + "testMap" )
    .SetRotation( 5, 0, 0 )
    .SetTexture( texMap );
    __renderer.AddModel( __mapModel );
    __drawSurface = -1;
    
    __renderer.__renderProperties.modelScale = 256;
    __renderer.__renderProperties.resolution = 1.5;
    __renderer.__renderProperties.fullBright = true;
    #endregion
    /* 
        brushProperties <- The properties that the map brush will be drawn with
    */
    brushProperties = {
        sprite : __animoFallbackSprite,
        colour : c_white
    }
    isDrawing = false;
    
    static GetDrawSurface = function() {
        if ( !surface_exists( __drawSurface ) ) {
            __drawSurface = surface_create( __renderProperties.width * __renderProperties.resolution, __renderProperties.height * __renderProperties.resolution );
        }
        
        return __drawSurface;
    }
    static SetDrawSurface = function( surface ) {
    	if ( surface_exists( surface ) ) {
    		__drawSurface = surface;
    	}
    	else {
    		__drawSurface = GetDrawSurface();
    	}
    }
    
    static Tick = function() {
        __renderer.Tick();
        
        if ( mouse_check_button( mb_left ) ) {
            // var _brush = instance_create_depth( 
            //     mouse_x,
            //     mouse_y,
            //     -3072,
            //     __brush,
            //     {
            //         __renderSurface : __renderer.GetRenderSurface(),
            //         __brushProperties : brushProperties
            //     }
            // );
            isDrawing = true;
        }
        else {
            isDrawing = false;
        }
    }
    static DrawMap = function() {
        __renderer.DrawModels();
        
                
        var _scaleX = ( __renderProperties.width / 2 ) / ( sprite_get_width( brushProperties.sprite ) );
        var _scaleY = ( __renderProperties.height / 2 ) / ( sprite_get_height( brushProperties.sprite ) );
        var _drawX = mouse_x - ( sprite_get_width( brushProperties.sprite ) * _scaleX / 2 );
        var _drawY = mouse_y - ( sprite_get_height( brushProperties.sprite ) * _scaleY / 2 );
        
        draw_sprite( brushProperties.sprite, -1, mouse_x, mouse_y );
        draw_text( 
            mouse_x, 
            mouse_y, 
            $"{mouse_x},{mouse_y}" 
        );
        
        if ( isDrawing ) {
            surface_set_target( __renderer.GetRenderSurface() ); {
                draw_clear_alpha( c_white, 1 );
                camera_apply( global.camera.GetCamera() );
                
                draw_sprite_stretched_ext( 
                    brushProperties.sprite, 
                    -1, 
                    _drawX, 
                    _drawY,
                    _scaleX,
                    _scaleY,
                    brushProperties.colour,
                    1
                );
                draw_set_colour( c_black );
                gpu_set_blendmode( bm_subtract );
                draw_text( _drawX, _drawY, $"{_drawX},{_drawY}" );
            }
            draw_reset();
            surface_reset_target();
            
            var _surfaceSprite = sprite_create_from_surface( __renderer.GetRenderSurface(), 0, 0, __renderProperties.width * __renderProperties.resolution, __renderProperties.height * __renderProperties.resolution, false, false, 0, 0 );
            
            __mapModel.SetTexture( _surfaceSprite );
        }
    }
}