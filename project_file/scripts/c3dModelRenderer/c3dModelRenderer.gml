function modelRenderer() {
    static renderer = new c3dModelRenderer();
    return renderer;
}
function c3dModelRenderer() constructor {
    #region Private
    __models = [];
    __renderSurface = -1;
    __renderSurfaceProperties = {
        width : __GAME_WIDTH,
        height : __GAME_HEIGHT,
        scale : 1,
        position : new Vector2( 0, 0 ),
        format : surface_rgba8unorm
    };
    #endregion
    #region Class Properties
    drawEnabled = true;
    #endregion
    
    static GetRenderSurface = function() {
        if ( !surface_exists( __renderSurface ) ) {
            __renderSurface = surface_create( __renderSurfaceProperties.width * __renderSurfaceProperties.scale, __renderSurfaceProperties.height * __renderSurfaceProperties.scale );
            // __renderSurface = surface_create( __renderSurfaceProperties.width * __renderSurfaceProperties.scale, __renderSurfaceProperties.height * __renderSurfaceProperties.scale, __renderSurfaceProperties.format );
        }
        
        return __renderSurface;
    }
    
    static AddModel = function( model ) {
        if ( !is_instanceof( model, c3dModel ) ) {
            throw $"Cannot add non 3d Model";
        }
        
        array_push( __models, model );
        
        var _modelTransform = model.GetTransform().origin;
        console().PrintExt( $"Added New Model at : {_modelTransform.x},{_modelTransform.y},{_modelTransform.z}" );
        console().PrintExt( $"Matrix : {model.transformMatrix}" );
        
        return self;
    }
    static GetModel = function( modelName ) {
        var _desiredModel = undefined;
        var _desiredModelName = string_lower( modelName );
        var _modelListSized = array_length( __models );
        
        for( var i = 0; i < _modelListSized; ++i ) {
            var _currentModel = __models[i];
            var _currentModelName = string_lower( __models[i].name );
            
            if ( _currentModelName == _desiredModelName ) {
                _desiredModel = _currentModel;
                break;
            }
        }
        
        return _desiredModel;
    }
    
    static Tick = function() {
        // Rebuilding the render surface if it suddenly doesn't exist.s
        __renderSurface = GetRenderSurface();
        __renderSurfaceProperties.position.x = global.camera.position.x;
        __renderSurfaceProperties.position.y = global.camera.position.y;
        // __renderSurfaceProperties.width *= global.camera.camScale;
        // __renderSurfaceProperties.height *= global.camera.camScale;
        // __renderSurfaceProperties.scale = global.camera.camScale;
    }
    
    static DrawModel = function( modelName ) {
        var _modelName = string_lower( modelName );
        var _modelToDraw = GetModel( _modelName );
        
        surface_set_target( GetRenderSurface() ); {
            draw_clear_alpha( c_white, 0 );
            camera_apply( global.camera.GetCamera() );
		    gpu_set_zwriteenable( true );
		    gpu_set_ztestenable( false );
		    
            if ( !is_undefined( _modelToDraw ) ) {
		        draw_text( 0, 0, $"words." );
                
                matrix_set( matrix_view, _modelToDraw.GetTransformMatrix() );
                
                vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
                
                matrix_set( matrix_view, matrix_build_identity() );
                
            }
        };
        
        surface_reset_target();
        draw_reset();
        
        draw_rectangle( __renderSurfaceProperties.position.x - 1, __renderSurfaceProperties.position.y - 1, __renderSurfaceProperties.position.x + surface_get_width( __renderSurface ), __renderSurfaceProperties.position.y + surface_get_height( __renderSurface ), true );
        draw_surface_stretched( GetRenderSurface(), __renderSurfaceProperties.position.x, __renderSurfaceProperties.position.y, __renderSurfaceProperties.width, __renderSurfaceProperties.height );
    }
    static DrawModels = function() {
        
    }
}