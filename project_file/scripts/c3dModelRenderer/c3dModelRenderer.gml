function modelRenderer() {
    static renderer = new c3dModelRenderer();
    return renderer;
}
function c3dModelRenderer() constructor {
    #region Private
    enum RENDER_TYPE {
    	WORLD,
    	VIEWPORT
    }
    __models = [];
    __currentModel = 0;
    __renderSurface = -1;
    __renderProperties = {
        width : __GAME_WIDTH,
        height : __GAME_HEIGHT,
        renderType : RENDER_TYPE.VIEWPORT,
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
    static GetRenderProperties = function() {
    	return __renderProperties;
    }
    
    static SetRenderProperty = function( propertyKey, propertyValue ) {
    	var _propertyKey = string_lower( propertyKey );
    	var _propertyValueType = typeof( struct_get( GetRenderProperties(), _propertyKey ) );
    	
    	if ( struct_get( __renderProperties, _propertyKey ) ) {
    		var _heldPropertyType = typeof( __renderProperties[$ _propertyKey] );
    		
    		if ( _propertyValueType == _heldPropertyType ) {
    			__renderProperties[$ _propertyKey] = propertyValue;
    		}
    	}
    	
    	return self;
    }
    /// @desc Render Surface is set to a new target. If target doesn't exist, then we fallback to the default one.
    static SetRenderSurface = function( surface ) {
    	if ( surface_exists( surface ) ) {
    		__renderSurface = surface;
    	}
    	else {
    		__renderSurface = GetRenderSurface();
    	}
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
        // Rebuilding the render surface if it suddenly doesn't exist.
        __renderSurface = GetRenderSurface();
        __renderProperties.position.x = global.camera.position.x;
        __renderProperties.position.y = global.camera.position.y;
        
        var _inputLeftRight = ( keyboard_check( ord( "D" ) ) - keyboard_check( ord( "A" ) ) );
        var _inputUpDown = ( keyboard_check( ord( "W" ) ) - keyboard_check( ord( "S" ) ) );
        var _inputMagnitude = point_distance( 0, 0, _inputLeftRight, _inputUpDown );
        
        var _pitchSpeed = _inputUpDown * 2;
        var _yawSpeed = _inputLeftRight * 2;
        var _rollSpeed = _inputLeftRight * 2;
        var _scale = 0.85;
        
        if ( !is_undefined( __models[__currentModel] ) ) {
        	if ( mouse_wheel_up() ) {
        		__renderProperties.modelScale += _scale;
        		__renderProperties.modelScale += _scale;
        		__renderProperties.modelScale += _scale;
        	}        	
        	if ( mouse_wheel_down() ) {
        		__renderProperties.modelScale -= _scale;
        		__renderProperties.modelScale -= _scale;
        		__renderProperties.modelScale -= _scale;
        	}
            
            __models[__currentModel].transform.rotation.x += _pitchSpeed;
            // __models[__currentModel].transform.rotation.y += _yawSpeed;
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
		    gpu_set_tex_repeat( true );
		    
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
            	
            	_modelToDraw.SetScale( __renderProperties.modelScale, __renderProperties.modelScale, __renderProperties.modelScale );
            	_modelToDraw.SetRotation( _modelRotation.x, _modelRotation.y, _modelRotation.z );
            	_modelToDraw.SetPosition( _modelOrigin.x, _modelOrigin.y, _modelOrigin.z );
            	
            	var _finalTransformMatrix = matrix_multiply(
            		matrix_multiply( 
            			_modelToDraw.GetScaleMatrix(), _modelToDraw.GetRotationMatrix() ),
            			_modelToDraw.GetTransformMatrix() 
            		);
            	
                matrix_set( matrix_world, _finalTransformMatrix );
                
                if ( __renderProperties.renderType == RENDER_TYPE.VIEWPORT ) {
                    matrix_set( matrix_view, _viewMatrix );
                    matrix_set( matrix_projection, _projMatrix );
                }
                
                vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
                
                matrix_set( matrix_world, matrix_build_identity() );
                matrix_set( matrix_view, _viewMatrix );
                matrix_set( matrix_projection, _projMatrix );
            }
            gpu_set_tex_repeat( false );
            shader_reset();
            surface_reset_target();
            draw_reset();
            draw_text( 0, 0, $"{_modelRotation.x},{_modelRotation.y},{_modelRotation.z}" );
        };

        draw_rectangle( __renderProperties.position.x - 1, __renderProperties.position.y - 1, __renderProperties.position.x + surface_get_width( __renderSurface ), __renderProperties.position.y + surface_get_height( __renderSurface ), true );
        draw_surface_stretched( GetRenderSurface(), __renderProperties.position.x, __renderProperties.position.y, __renderProperties.width, __renderProperties.height );
    }
    static DrawModels = function() {
        var _modelListSize = array_length( __models );
        
        for( var i = 0; i < _modelListSize; ++i ) {
        	var _currentModel = __models[i].name;
        	
        	DrawModel( _currentModel );
        }
    }
}