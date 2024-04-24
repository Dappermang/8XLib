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
        modelScale : 1,
        position : new Vector2( 0, 0 ),
        fullBright : false,
        drawOverlays : true,
        format : surface_rgba8unorm
    };
    #endregion
    #region Class Properties
    drawEnabled = true;
    resetTransforms = false;
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
    static GetCurrentModel = function() {
    	var _result = undefined;
    	
    	if ( array_length( __models ) > 0 ) {
    		_result = __models[__currentModel];
    	}
    	
    	return _result;
    }
    static ResetModelTransforms = function() {
    	GetCurrentModel().transform.rotation.x = lerp( GetCurrentModel().transform.rotation.x, 0, 0.1 );
    	GetCurrentModel().transform.rotation.y = lerp( GetCurrentModel().transform.rotation.y, 0, 0.1 );
    	GetCurrentModel().transform.rotation.z = lerp( GetCurrentModel().transform.rotation.z, 0, 0.1 );
    }
    static Tick = function() {
        // Rebuilding the render surface if it suddenly doesn't exist.
        __renderSurface = GetRenderSurface();
        
        var _camera = global.camera;
        var _cameraPosition = _camera.GetCameraViewPosition();
        var _cameraViewSize = _camera.GetCameraSize();
        
        __renderProperties.position.x = _cameraPosition.x;
        __renderProperties.position.y = _cameraPosition.y;
        __renderProperties.width = _cameraViewSize.x;
        __renderProperties.height = _cameraViewSize.y;
        
        // var _aspectRatio = __renderProperties.width / __renderProperties.height;
        
        // __renderProperties.modelScale = __renderProperties.modelScale / _aspectRatio;
        
        var _inputLeftRight = ( keyboard_check( ord( "D" ) ) - keyboard_check( ord( "A" ) ) );
        var _inputYaw = ( keyboard_check( ord( "E" ) ) - keyboard_check( ord( "Q" ) ) );
        var _inputUpDown = ( keyboard_check( ord( "W" ) ) - keyboard_check( ord( "S" ) ) ); 
        
        var _inputLeftRight2 = ( keyboard_check( vk_left ) - keyboard_check( vk_right ) );
        var _inputYaw2 = ( keyboard_check( ord( "E" ) ) - keyboard_check( ord( "Q" ) ) );
        var _inputUpDown2 = ( keyboard_check( vk_up ) - keyboard_check( vk_down ) );
        
        var _pitchSpeed = _inputUpDown * 2;
        var _yawSpeed = _inputYaw * 2;
        var _rollSpeed = _inputLeftRight * 2;  
        
        var _pitchSpeed2 = _inputUpDown2 * 2;
        var _yawSpeed2 = _inputYaw2 * 2;
        var _rollSpeed2 = _inputLeftRight2 * 2;
        var _scale = 0.5;
        
        if ( keyboard_check_pressed( vk_backspace ) ) {
        	drawEnabled = !drawEnabled;
        }
        if ( !is_undefined( __models[__currentModel] ) ) {
        	if ( keyboard_check_pressed( ord( "R" ) ) ) {
        		resetTransforms = !resetTransforms;
        	}
        	if ( resetTransforms ) {
        		ResetModelTransforms();
        	}
            
            __models[__currentModel].transform.rotation.x += _pitchSpeed2;
            __models[__currentModel].transform.rotation.y += _yawSpeed2;
            __models[__currentModel].transform.rotation.z += _rollSpeed2;
            
            __models[__currentModel].transform.origin.x += _pitchSpeed;
            __models[__currentModel].transform.origin.y += _yawSpeed;
            __models[__currentModel].transform.origin.z += _rollSpeed;
        }
    }
    
    static __renderModel = function( modelName ) {
        var _modelName = string_lower( modelName );
        var _modelToDraw = GetModel( _modelName );
           
        if ( is_undefined( _modelToDraw ) ) {
        	return;
        }
		
        var _viewMatrix = global.camera.GetViewMatrix();
        var _projMatrix = global.camera.GetProjectionMatrix();
		
        var _modelTransform = _modelToDraw.GetTransform();
        var _modelOrigin = _modelToDraw.GetTransform().origin;
        var _modelRotation = _modelToDraw.GetTransform().rotation;
        var _modelScale = _modelToDraw.GetTransform().scale;
        
        _modelToDraw.SetScale( 
        	_modelScale.x, 
        	_modelScale.y, 
        	_modelScale.z 
        );
        _modelToDraw.SetRotation( 
        	_modelRotation.x, 
        	_modelRotation.y,
        	_modelRotation.z 
        );
        _modelToDraw.SetPosition( 
        	_modelOrigin.x, 
        	_modelOrigin.y,
        	_modelOrigin.z 
        );
        
        var _finalTransformMatrix = _modelToDraw.GetFinalMatrix();
        
        matrix_set( matrix_world, _finalTransformMatrix );
        
        if ( __renderProperties.renderType == RENDER_TYPE.VIEWPORT ) {
            matrix_set( matrix_view, _viewMatrix );
            matrix_set( matrix_projection, _projMatrix );
        }
        
        /* 
            This can probably be done better.
            For the future consider ; 
                - A list of available textures for overlay ?
        */
        if ( !is_undefined( _modelToDraw.overlayTexture ) ) {
        	shader_set( shdBakeTex );
        	
        	var _mouseCoordinatesNormalized = global.camera.GetMousePositionNormalized();
        	var _u_Matrix = shader_get_uniform( shdBakeTex, "u_vMatrix" );
        	var _u_BaseSample = shader_get_sampler_index( shdBakeTex, "u_vBaseTexture" );
        	var _u_OverlaySample = shader_get_sampler_index( shdBakeTex, "u_vOverlayTexture" );
        	
        	shader_set_uniform_matrix_array( _u_Matrix, _finalTransformMatrix );
        	texture_set_stage( _u_BaseSample, _modelToDraw.GetTexture() );
        	texture_set_stage( _u_OverlaySample, _modelToDraw.overlayTexture );
        }
        
        vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
        
        matrix_set( matrix_world, MATRIX_IDENTITY );
    }
    static DrawModels = function() {
        if ( !drawEnabled ) {
        	return;
        }
        
		if ( !__renderProperties.fullBright ) {
			shader_set( shdDiffuse );
		}
        
        var _modelListSize = array_length( __models );
        
        surface_set_target( GetRenderSurface() ); {
            draw_clear_alpha( c_black, 0 );
            
		    gpu_set_zwriteenable( true );
		    gpu_set_ztestenable( true );
		    gpu_set_tex_repeat( true );
            
            for( var i = 0; i < _modelListSize; ++i ) {
            	var _currentModel = __models[i].name;
            	
            	__renderModel( _currentModel );
            }
        }
        
		gpu_set_zwriteenable( false );
		gpu_set_ztestenable( false );
		gpu_set_tex_repeat( false );
		
        shader_reset();
        surface_reset_target();
        draw_reset();
        
        draw_set_color( c_aqua );
        draw_roundrect(
            __renderProperties.position.x - 1, 
            __renderProperties.position.y - 1, 
            __renderProperties.position.x + __renderProperties.width - 1, 
            __renderProperties.position.y + __renderProperties.height - 1,
            true
        );
        draw_circle(
        	__renderProperties.position.x,
        	__renderProperties.position.y,
        	8,
        	false
        );
        draw_set_color( c_white );
        draw_surface_stretched(
        	GetRenderSurface(), 
        	__renderProperties.position.x, 
        	__renderProperties.position.y, 
        	__renderProperties.width, 
        	__renderProperties.height 
        );
    }
}