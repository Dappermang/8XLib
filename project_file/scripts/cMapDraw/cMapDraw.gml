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
    .SetScale( 256 )
    .SetTextureFromSprite( texMap );
    __renderer.AddModel( __mapModel );
    __drawSurface = -1;
    
    __renderer.width = texture_get_width( __mapModel.GetTexture() );
    __renderer.height = texture_get_height( __mapModel.GetTexture() );
    
    __renderer.__renderProperties.resolution = 1.5;
    __renderer.__renderProperties.fullBright = true;
    #endregion
    /* 
        brushProperties <- The properties that the map brush will be drawn with
    */
    brushProperties = {
        sprite : __animoFallbackSprite,
        size : 4,
        currentColour : 0,
        colours : [
            c_red,
            c_green,
            c_blue,
            c_black,
        ]
    }
    mousePositionPrevious = global.camera.GetMousePosition();
    isDrawing = false;
    
    static Serialize = function() {
        var _saveBuffer = buffer_create( 0, buffer_grow, 1 );
        
        buffer_get_surface( _saveBuffer, GetDrawSurface(), 0 );
        buffer_save( _saveBuffer, CACHE_PATH + "map01.data" );
        buffer_delete( _saveBuffer );
    }
    static Deserialize = function() {
        var _saveBuffer = buffer_load( CACHE_PATH + "map01.data" );
        
        buffer_set_surface( _saveBuffer, GetDrawSurface(), 0 );
    }
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
        
        if ( keyboard_check_pressed( vk_f6 ) ) {
            Serialize();
        }         
        if ( keyboard_check_pressed( vk_f7 ) ) {
            Deserialize();
        }
        if ( mouse_wheel_up() ) {
            brushProperties.currentColour = ( brushProperties.currentColour + 1 ) % ( array_length( brushProperties.colours ) );
        }       
        if ( mouse_wheel_down() ) {
            brushProperties.currentColour = ( brushProperties.currentColour - 1 + array_length( brushProperties.colours ) ) % ( array_length(brushProperties.colours ) );
        }
        
        var _camera = global.camera;
        var _cameraID = _camera.GetCamera();
        var _cameraPosition = _camera.GetPosition2D();
        var _cameraViewPosition = _camera.GetViewPosition();
        var _cameraMousePosition = _camera.GetMousePosition();
        var _cameraMousePositionNormalized = _camera.GetMousePositionNormalized();
        
        var _scaleX = ( __renderProperties.width / 2 ) / ( sprite_get_width( brushProperties.sprite ) );
        var _scaleY = ( __renderProperties.height / 2 ) / ( sprite_get_height( brushProperties.sprite ) );
        
        var _viewMatrix = global.camera.GetViewMatrix();
        var _projMatrix = global.camera.GetProjectionMatrix();
        
        // Paint to surface.
        surface_set_target( GetDrawSurface() ); {
            camera_apply( _cameraID );
            if ( mouse_check_button( mb_left ) ) {
                isDrawing = true;
                
                var _modelMatrix = __renderer.GetCurrentModel().GetFinalMatrix();
                var _viewMatrix = global.camera.GetViewMatrix();
                var _projMatrix = global.camera.GetProjectionMatrix();
                
                // matrix_set( matrix_world, _modelMatrix );
                // matrix_set( matrix_view, _viewMatrix );
                // matrix_set( matrix_projection, _projMatrix );
                draw_line_width_color(
                    _cameraMousePosition.x,
                    _cameraMousePosition.y,
                    mousePositionPrevious.x,
                    mousePositionPrevious.y,
                    brushProperties.size,
                    brushProperties.colours[brushProperties.currentColour],
                    brushProperties.colours[brushProperties.currentColour]
                );
            }
            if ( mouse_check_button( mb_right )
            && !isDrawing ) {
                gpu_set_blendmode( bm_subtract );
                draw_circle_colour(
                    _cameraMousePosition.x,
                    _cameraMousePosition.y,
                    4,
                    c_black,
                    c_black,
                    false
                );
            }
            if ( isDrawing ) {
                __renderer.GetCurrentModel().SetOverlayTextureFromSurface( GetDrawSurface() );
                isDrawing = false;
            }
        }
        draw_reset();
        surface_reset_target();
        
        mousePositionPrevious = _cameraMousePosition;
    }
    static DrawMap = function() {
        __renderer.DrawModels();
        
        var _camera = global.camera;
        var _cameraID = _camera.GetCamera();
        var _cameraPosition = _camera.GetPosition2D();
        var _cameraViewPosition = _camera.GetViewPosition();
        var _cameraViewSize = _camera.GetSize();
        var _cameraMousePosition = _camera.GetMousePosition();
        var _cameraMousePositionPrevious = _cameraMousePosition;
        
        #region Debug Draw
        draw_rectangle(
            _cameraViewPosition.x,
            _cameraViewPosition.y, 
            _cameraViewPosition.x + __renderProperties.width * _cameraViewSize.x, 
            _cameraViewPosition.y + __renderProperties.height * _cameraViewSize.y,
            true
        );
        
        // draw_sprite_ext(
        //     texMap,
        //     -1,
        //     0,
        //     0,
        //     1,
        //     1, 
        //     0,
        //     c_white,
        //     1
        // );
        // draw_surface_stretched( 
        //     GetDrawSurface(),
        //      _cameraViewPosition.x, 
        //      _cameraViewPosition.y, 
        //     __renderProperties.width, 
        //     __renderProperties.height
        // );
        #endregion
        
        // var _modelMatrix = __renderer.GetCurrentModel().GetFinalMatrix();
        // var _viewMatrix = global.camera.GetViewMatrix();
        // var _projMatrix = global.camera.GetProjectionMatrix();
        
        // matrix_set( matrix_world, _modelMatrix );
        // matrix_set( matrix_view, _viewMatrix );
        // matrix_set( matrix_projection, _projMatrix );
        // draw_circle( mouse_x, mouse_y, 1, false );
        // matrix_set( matrix_world, MATRIX_IDENTITY );
        
        // Drawing the brush outlines
        // draw_circle_colour(
        //     _cameraMousePosition.x,
        //     _cameraMousePosition.y,
        //     brushProperties.size,
        //     c_black,
        //     c_black,
        //     true
        // );
        //
        
        var _cameraMousePositionNormalized = global.camera.GetMousePositionNormalized();
        
        draw_text(
            _cameraMousePosition.x,
            _cameraMousePosition.y,
            $"{_cameraMousePositionNormalized.x},{_cameraMousePositionNormalized.y}"
        );
        
        /*
            Map Painting Idea;
            - 'Paint' directly on a Draw Surface
            - Get texture of surface
            - Map that texture to the model using a shader
        */
    }
}