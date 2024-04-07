function modelRenderer() {
    static renderer = new c3dModelRenderer();
    return renderer;
}
function c3dModelRenderer() constructor {
    #region Private
    __models = [];
    __currentModel = 0;
    __renderSurface = -1;
    __renderProperties = {
        width : __GAME_WIDTH,
        height : __GAME_HEIGHT,
        resolution : 1,
        modelScale : 32,
        position : new Vector2( 0, 0 ),
        fullBright : false,
        format : surface_rgba8unorm
    };
    #endregion
    #region Class Properties
    drawEnabled = true;
    #endregion
    
    static GetRenderSurface = function() {
        if ( !surface_exists( __renderSurface ) ) {
            __renderSurface = surface_create( __renderProperties.width * __renderProperties.resolution, __renderProperties.height * __renderProperties.resolution );
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
        __renderProperties.position.x = global.camera.position.x;
        __renderProperties.position.y = global.camera.position.y;
        
        var _inputLeftRight = ( keyboard_check( ord( "A" ) ) - keyboard_check( ord( "D" ) ) );
        var _inputUpDown = ( keyboard_check( ord( "S" ) ) - keyboard_check( ord( "W" ) ) );
        var _inputMagnitude = point_distance( 0, 0, _inputLeftRight, _inputUpDown );
        
        var _pitchSpeed = _inputUpDown * 2;
        var _yawSpeed = _inputLeftRight * 2;
        var _rollSpeed = _inputLeftRight * 2;
        
        if ( !is_undefined( __models[__currentModel] ) ) {
            // __models[__currentModel].transform.origin.x += _pitchSpeed;
            // __models[__currentModel].transform.origin.y += _yawSpeed;
            // __models[__currentModel].transform.origin.z += _rollSpeed;
            
            __models[__currentModel].transform.rotation.x += _pitchSpeed;
            __models[__currentModel].transform.rotation.z += _rollSpeed;
        }
    }
    
    static DrawModel = function( modelName ) {
        var _modelName = string_lower( modelName );
        var _modelToDraw = GetModel( _modelName );
        
        surface_set_target( GetRenderSurface() ); {
            draw_clear_alpha( c_black, 0 );
            camera_apply( global.camera.GetCamera() );
		    gpu_set_zwriteenable( true );
		    gpu_set_ztestenable( true );
		    
		    if ( !__renderProperties.fullBright ) {
		    	shader_set( shdDiffuse );
		    }
		    
            var _viewMatrix = global.camera.GetViewMatrix();
            var _projMatrix = global.camera.GetProjectionMatrix();
		    
            if ( !is_undefined( _modelToDraw ) ) {
            	var _modelTransform = _modelToDraw.GetTransform();
            	var _modelOrigin = _modelToDraw.GetTransform().origin;
            	var _modelRotation = _modelToDraw.GetTransform().rotation;
            	var _modelScale = _modelToDraw.GetTransform().scale;
            	
            	_modelToDraw.SetScale( __renderProperties.modelScale, -__renderProperties.modelScale, -__renderProperties.modelScale );
            	_modelToDraw.SetRotation( _modelRotation.x, _modelRotation.y, _modelRotation.z );
            	_modelToDraw.SetPosition( _modelOrigin.x, _modelOrigin.y, _modelOrigin.z );
            	
            	var _finalTransformMatrix = matrix_multiply(
            		matrix_multiply( 
            			_modelToDraw.GetScaleMatrix(), _modelToDraw.GetRotationMatrix() ),
            			_modelToDraw.GetTransformMatrix() 
            		);
            	
                matrix_set( matrix_world, _finalTransformMatrix );
                matrix_set( matrix_view, _viewMatrix );
                matrix_set( matrix_projection, _projMatrix );
                
                vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
                
                matrix_set( matrix_world, matrix_build_identity() );
                matrix_set( matrix_view, matrix_build_identity() );
                matrix_set( matrix_projection, matrix_build_identity() );
            }
            surface_reset_target();
            draw_reset();
        };

        draw_rectangle( __renderProperties.position.x - 1, __renderProperties.position.y - 1, __renderProperties.position.x + surface_get_width( __renderSurface ), __renderProperties.position.y + surface_get_height( __renderSurface ), true );
        draw_surface_stretched( GetRenderSurface(), __renderProperties.position.x, __renderProperties.position.y, __renderProperties.width, __renderProperties.height );
    }
    static DrawModels = function() {
        
    }
}