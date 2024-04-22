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
    .SetTextureFromSprite( texMap );
    __renderer.AddModel( __mapModel );
    __drawSurface = -1;
    
    __renderer.__renderProperties.modelScale = 256;
    __renderer.__renderProperties.resolution = 1.5;
    __renderer.__renderProperties.fullBright = true;
    
    _mousePosition = new Vector2(
        mouse_x - camera_get_view_x( global.camera.GetCamera() ),
        mouse_y - camera_get_view_y( global.camera.GetCamera() ) 
    );
    _mousePositionPrevious = _mousePosition;
    #endregion
    /* 
        brushProperties <- The properties that the map brush will be drawn with
    */
    brushProperties = {
        sprite : __animoFallbackSprite,
        size : 4,
        colour : c_black,
        color : c_black
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
        
        _mousePosition = new Vector2(
            mouse_x - camera_get_view_x( global.camera.GetCamera() ),
            mouse_y - camera_get_view_y( global.camera.GetCamera() ) 
        );
        
        var _scaleX = ( __renderProperties.width / 2 ) / ( sprite_get_width( brushProperties.sprite ) );
        var _scaleY = ( __renderProperties.height / 2 ) / ( sprite_get_height( brushProperties.sprite ) );
        
        surface_set_target( GetDrawSurface() ); {
            if ( mouse_check_button( mb_left ) ) {
                isDrawing = true;
                
                draw_line_width_color(
                    _mousePosition.x,
                    _mousePosition.y,
                    _mousePositionPrevious.x,
                    _mousePositionPrevious.y,
                    brushProperties.size,
                    brushProperties.colour,
                    brushProperties.colour
                );
                // draw_sprite_stretched_ext(
                //     brushProperties.sprite, 
                //     -1, 
                //     _mousePosition.x, 
                //     _mousePosition.y,
                //     _scaleX,
                //     _scaleY,
                //     brushProperties.colour,
                //     1
                // );
            }
                
            if ( isDrawing ) {
                __renderer.GetCurrentModel().SetOverlayTextureFromSurface( GetDrawSurface() );
                isDrawing = false;
            }
            if ( mouse_check_button( mb_right ) ) {
                gpu_set_blendmode( bm_subtract );
                draw_circle_colour(
                    _mousePosition.x,
                    _mousePosition.y,
                    4,
                    c_black,
                    c_black,
                    false
                );
            }
        }
        draw_reset();
        surface_reset_target();
        
        _mousePositionPrevious = _mousePosition;
    }
    static DrawMap = function() {
        __renderer.DrawModels();
        
        // Drawing the brush outlines
        draw_circle_colour(
            _mousePosition.x,
            _mousePosition.y,
            brushProperties.size,
            c_black,
            c_black,
            true
        );
        
        /*
            Map Painting Idea;
            - 'Paint' directly on a Draw Surface
            - Get texture of surface
            - Map that texture to the model using a shader
        */
        // draw_surface_stretched( GetDrawSurface(), __renderProperties.position.x, __renderProperties.position.y, __renderProperties.width, __renderProperties.height );
    }
}