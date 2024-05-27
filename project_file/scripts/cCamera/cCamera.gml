function cCamera() class {
	#region Private
	__camID = 0;
	__camera = -1;
	
	view_camera[__camID] = camera_create();
	__Init();
		
	static __Init = function() {
		window_set_colour( c_white );
		// Set the corresponding view to the __camera ID and create a new __camera.
		__camera = view_camera[__camID];
		view_set_camera( view_current, __camera );
		view_set_visible( view_current, true );
	}
	#endregion
	#region Public
	// The camera resolution ( what the game is rendered at before being upscaled )
	camWidth = __GAME_RES_WIDTH;
	camHeight = __GAME_RES_HEIGHT;
	camAspectRatio = GetAspectRatio();
	camRenderSurface = -1;
	camBBox = new Vector2( room_width, room_height );
	camBBoxSize = 32;// __camera bound box size used for movement
	camAngle = 0;
	camResolutionScale = 1;
	camMaxScale = 8;
	camFov = 90;
	camApproachFactor = 0.0075;// The speed at which the camera will move towards its focus position
	camClipDistanceNear = -3072;
	camClipDistanceFar = 3072;
	
	focusPosition = undefined;
	transform = new cTransform3D();
	position = new Vector3( 0, 0, -512 );
	
	projMatrix = undefined;
	viewMatrix = undefined;
    mousePosition = new Vector2(
        mouse_x - camera_get_view_x( __camera ),
        mouse_y - camera_get_view_y( __camera ) 
    );
	// Animation curves used for 'zoom' and 'shake' FX
	zoomCurve = undefined;
	shakeCurve = undefined;
	#endregion
	SetOrthographicProjection();//temp
	#region Get
	static GetCamera = function() {
		return __camera;
	}
	static GetAspectRatio = function() {
		return camWidth / camHeight;
	}
    static GetRenderSurface = function() {
        if ( !surface_exists( camRenderSurface ) ) {
            camRenderSurface = surface_create( camWidth * camResolutionScale, camHeight * camResolutionScale );
        }
        
        return camRenderSurface;
    }
	static GetProjectionMatrix = function() {
		return projMatrix;
	}
	static GetViewMatrix = function() {
		return viewMatrix;
	}
	static GetMouseDirFromCenter = function() {
		return point_direction( position.x + ( camWidth / 2 ) * camResolutionScale, position.y + ( camHeight / 2 ) * camResolutionScale, mouse_x, mouse_y );
	}
	
	static GetMouseDisFromCenter = function() {
		return point_distance( position.x + ( camWidth / 2 ) * camResolutionScale, position.y + ( camHeight / 2 ) * camResolutionScale, mouse_x, mouse_y );
	}
	
	static GetFocusDirFromCenter = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_direction( position.x + ( camWidth / 2 ) * camResolutionScale, position.y + ( camHeight / 2 ) * camResolutionScale, focusPosition.x, focusPosition.y );
		}
		else {
			show_debug_message( "No focus position defined." );
		}
	}
	static GetFocusDisFromCenter = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_distance( position.x + ( camWidth / 2 ) * camResolutionScale, position.y + ( camHeight / 2 ) * camResolutionScale, focusPosition.x, focusPosition.y );
		}
		else {
			show_debug_message( "No focus position defined." );
		}
	}
	static GetMousePosition = function() {
        return new Vector2(
            ( mouse_x + GetPosition2D().x ) - GetViewPosition().x,
            ( mouse_y + GetPosition2D().y ) - GetViewPosition().y 
        );
	}
	static GetMousePositionNormalized = function() {
	    var _cameraPosition = GetViewPosition();
	    var _cameraSize = GetSize();
	
	    var _mouseXRelativeToCamera = mouse_x - _cameraPosition.x;
	    var _mouseYRelativeToCamera = mouse_y - _cameraPosition.y;
	
	    var _cameraWidth = _cameraSize.x;
	    var _cameraHeight = _cameraSize.y;
	
	    var _normalizedMouseX = _mouseXRelativeToCamera / _cameraWidth;
	    var _normalizedMouseY = _mouseYRelativeToCamera / _cameraHeight;
	
	    // Return the normalized mouse position
	    return new Vector2( 
	    	_normalizedMouseX, 
	    	_normalizedMouseY 
	    );
	}
	/// @static
	/// @returns {struct} Vector2( center_x, center_y )
	static GetCenter = function() {
		var _center_x = ( camWidth / 2 ) * camResolutionScale;
		var _center_y = ( camHeight / 2 ) * camResolutionScale;
		
		return new Vector2( _center_x, _center_y );
	}	
	/// @static
	/// @returns {struct} Vector2( posX, posY )
	static GetPosition2D = function() {
		return new Vector2( position.x, position.y );
	}
	/// @static
	/// @returns {struct} Vector2
	static GetResolution = function() {
		return new Vector2( camera_get_view_width( __camera ), camera_get_view_height( __camera ) );
	}		
	/// @static
	/// @returns {struct} Vector2
	static GetSize = function() {
		return new Vector2( camera_get_view_width( __camera ) * camResolutionScale, camera_get_view_height( __camera ) * camResolutionScale );
	}	
	/// @static
	/// @returns {struct} Vector2
	static GetViewPosition = function() {
		return new Vector2( camera_get_view_x( __camera ), camera_get_view_y( __camera ) );
	}
	#endregion
	#region Set
	static SetRenderSurface = function( surface ) {
		if ( surface_exists( surface ) ) {
			camRenderSurface = surface;
		}
		else {
			camRenderSurface = GetRenderSurface();
		}
	}
	static SetOrthographicProjection = function() {
		// TODO: Add options for different projection types.
		projMatrix = matrix_build_projection_ortho( 
			__GAME_RES_WIDTH, __GAME_RES_HEIGHT, 
			-camClipDistanceNear, camClipDistanceFar 
		);
		
		var _targetX = position.x + dsin( camAngle );
		var _targetY = position.y + dcos( camAngle );
	
		viewMatrix = matrix_build_lookat( 
			position.x, position.y, position.z, 
			_targetX, _targetY, 0, 
			0, 0, 1
		);
	}
	/// @static
	static ClearFocus = function() {
		focusPosition = undefined;
	}
	static SetApproachFactor = function( _spd = 0.1 ) {
		camApproachFactor = _spd;
	} 
	static SetCameraPosition = function( _x, _y, _z = 0 ) {
		position.x = _x;
		position.y = _y;
		position.z = _z;
	}
	/// @static
	/// @desc Sets a new focus position using a Vec2
	/// @param {number} x
	/// @param {number} y
	static SetFocusPosition = function( _x, _y, _z = 0 ) {
		focusPosition = new Vector3( _x, _y, _z );
	}
	
	static SetFocusPositionAligned = function( _x, _y, _z = 0, align = CAM_ALIGN.MIDDLE ) {
		switch( align ) {
			case CAM_ALIGN.MIDDLE :// Middle
				focusPosition = new Vector3( _x, _y, _z );
				break;			
			case CAM_ALIGN.LEFT :// Left
				focusPosition = new Vector3( _x - ( camWidth / 2 ), _y, _z );
				break;			
			case CAM_ALIGN.RIGHT : // Right
				focusPosition = new Vector3( _x + ( camWidth / 2 ), _y, _z );
				break;			
			case CAM_ALIGN.TOP : // Top
				focusPosition = new Vector3( _x, _y - ( camHeight / 2 ), _z );
				break;			
			case CAM_ALIGN.BOTTOM : // Bottom
				focusPosition = new Vector3( _x, _y + ( camHeight / 2 ), _z );
				break;
		}
	}
	#endregion

	static Tick = function() {
    	mousePosition = GetMousePosition();
		
		if ( !is_undefined( focusPosition ) ) {
			var _camSize = GetSize();
			var _focusDir = GetFocusDirFromCenter();
			var _focusDis = GetFocusDisFromCenter();

			position.x += dcos( _focusDir ) * ( camApproachFactor * _focusDis );
			position.y -= dsin( _focusDir ) * ( camApproachFactor * _focusDis );
			
			position.x = median( _camSize.x / 2, position.x, camBBox.x - _camSize.x / 2 );
			position.y = median( _camSize.y / 2, position.y, camBBox.y - _camSize.y / 2 );
		}
		
		camApproachFactor *= camResolutionScale;
		
		if ( __CAM_DEBUG ) {
			if ( keyboard_check( vk_shift )
			&& mouse_check_button( mb_left ) ) {
				var _mouse_dir = GetMouseDirFromCenter();
	
				position.x += dcos( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
				position.y -= dsin( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
			}
			
			if ( keyboard_check( vk_up ) ) {
				camResolutionScale += 0.1;
			}			
			
			if ( keyboard_check( vk_down ) ) {
				camResolutionScale -= 0.1;
			}
			
			var _inputLeftRight = ( keyboard_check( ord( "D" ) ) - keyboard_check( ord( "A" ) ) );
			var _inputUpDown = ( keyboard_check( ord( "S" ) ) - keyboard_check( ord( "W" ) ) );
			var _inputMagnitude = point_distance( 0, 0, _inputLeftRight, _inputUpDown );
			
			var _pitchSpeed = _inputUpDown * 2;
			var _yawSpeed = _inputLeftRight * 2;
			var _rollSpeed = _inputLeftRight * 2;
			
			position.x += _yawSpeed;
			position.y += _pitchSpeed;
		}
	}
	// Draw END
	static DrawOverlay = function() {
		var _center_pos = GetCenter();
		var _x = camera_get_view_x( __camera );
		var _y = camera_get_view_y( __camera );
		
		draw_set_color( c_lime );
		draw_circle( _x + _center_pos.x, _y + _center_pos.y, 2, false );
		draw_text( _x + _center_pos.x, _y + _center_pos.y + 8, "__camera Center" );
		draw_set_color( c_white );
		
		draw_set_color( c_lime );
		draw_rectangle( _x, _y, _x + ( camWidth * camResolutionScale ), _y + ( camHeight * camResolutionScale ), true );
		draw_set_color( c_white );
	}
	
	static Prerender = function() {
		camera_set_proj_mat( __camera, projMatrix );
		camera_set_view_mat( __camera, viewMatrix );
	}
	
	// For use in the draw_pre event
	static Render = function() {
		draw_clear_alpha( c_black, 0 );
		draw_set_valign( fa_middle );
		draw_set_halign( fa_center );
		
		var _center_pos = GetCenter();
		
		camera_set_view_size( __camera, ( camWidth * camResolutionScale ), ( camHeight * camResolutionScale ) );
		camera_set_view_pos( __camera, position.x, position.y );
		
		gpu_set_zwriteenable( true );
		gpu_set_ztestenable( false );
		
		camWidth = clamp( camWidth, __GAME_RES_WIDTH / 2, __GAME_RES_WIDTH );
		camHeight = clamp( camHeight, __GAME_RES_HEIGHT / 2, __GAME_RES_HEIGHT );
		camAngle = clamp( camAngle, -360, 360 );
		camResolutionScale = clamp( camResolutionScale, 1, camMaxScale );
		
		camera_set_view_angle( __camera, camAngle );
		camera_apply( __camera );
		
		draw_set_valign( fa_top );
		draw_set_halign( fa_left );
	}
	
	static DrawDebug = function() {
		var _res = GetResolution();
		
		if ( __CAM_DEBUG ) {
			draw_set_color( c_lime );
			draw_text_transformed( position.x + 1, position.y, string( "__camera Resolution:{0} x {1}", _res.x, _res.y ), camResolutionScale, camResolutionScale, 0 );
			draw_text_transformed( position.x + 1 * camResolutionScale, position.y + 20 * camResolutionScale, string( "__camera Aspect:{0}", camAspectRatio ), camResolutionScale, camResolutionScale, 0 );
			
			draw_text_transformed( position.x + 1 * camResolutionScale, position.y + 40 * camResolutionScale, string( "Display Resolution:{0} x {1}", resolution_manager().displayWidth, resolution_manager().displayHeight ), camResolutionScale, camResolutionScale, 0 );
			draw_text_transformed( position.x + 1 * camResolutionScale, position.y + 60 * camResolutionScale, string( "Display Aspect:{0}", resolution_manager().aspectRatio ), camResolutionScale, camResolutionScale, 0 );
			draw_set_color( c_white );
			
			draw_arrow( mouse_x, mouse_y, mouse_x + lengthdir_x( 16, GetMouseDirFromCenter() ), mouse_y + lengthdir_y( 16, GetMouseDirFromCenter() ), 32 );
			
			draw_set_color( make_color_rgb( 90, 90, 90 ) );
			draw_rectangle( 0, 0, room_width, room_height, false );
			draw_set_color( c_white );
			
			draw_text( room_width / 2, room_height / 2, "Room Center" );
			draw_circle( room_width / 2, room_height / 2, 2, false );
		}
	}
}