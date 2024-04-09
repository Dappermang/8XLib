function cCamera() constructor {
	// Increment the Cam ID for every new instance of the __camera class
	camID = 0;
	camWidth = __GAME_WIDTH;
	camHeight = __GAME_HEIGHT;
	
	position = new Vector3( 0, 0, -512 );

	camSurface = surface_create( camWidth, camHeight );
	view_camera[camID] = camera_create();
	
	#region Private
	__camera = -1;
		
	static __Init = function() {
		window_set_colour( c_white );
		// Set the corresponding view to the __camera ID and create a new __camera.
		__camera = view_camera[camID];
		view_set_camera( view_current, __camera );
		view_set_visible( view_current, true );
	}
	#endregion
	
	__Init();
	
	// Animation curves used for 'zoom' and 'shake' FX
	zoomCurve = undefined;
	shakeCurve = undefined;
	
	camBBox = new Vector2( room_width, room_height );
	camAngle = 0;
	camScale = 1;
	camMaxScale = 8;
	camFov = 90;
	camAspectRatio = __GAME_WIDTH / __GAME_HEIGHT;
	camVelocity = 0;
	camApproachFactor = 0.0075;
	
	// TODO: camera "nudge" variable so that the camera can always pull to a certain direction / focus
	
	var _camX = camera_get_view_x( __camera ) + camera_get_view_width( __camera ) / 2;
	var _camY = camera_get_view_y( __camera ) + camera_get_view_height( __camera ) / 2;
	var _clippingDist = 3072;
	
	// TODO: Add options for different projection types.
	projMatrix = matrix_build_projection_ortho( 
		__GAME_WIDTH, __GAME_HEIGHT, 
		-_clippingDist, _clippingDist 
	);
	var _targetX = position.x + dsin( camAngle );
	var _targetY = position.y + dcos( camAngle );

	viewMatrix = matrix_build_lookat( 
		position.x, position.y, position.z, 
		_targetX, _targetY, 0, 
		0, 0, 1
	);
	
	static GetProjectionMatrix = function() {
		return projMatrix;
	}	
	static GetViewMatrix = function() {
		return viewMatrix;
	}
	
	// The direction the __camera will go based on velocity and other factors
	camDir = 0;
	
	// __camera bound box size used for movement
	camBBoxSize = 32;
	
	focusPosition = undefined;
	
	static GetCamera = function() {
		return __camera;
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
	
	static GetMouseDirFromCenter = function() {
		return point_direction( position.x + ( camWidth / 2 ) * camScale, position.y + ( camHeight / 2 ) * camScale, mouse_x, mouse_y );
	}
	
	static GetMouseDisFromCenter = function() {
		return point_distance( position.x + ( camWidth / 2 ) * camScale, position.y + ( camHeight / 2 ) * camScale, mouse_x, mouse_y );
	}
	
	static GetFocusDirFromCenter = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_direction( position.x + ( camWidth / 2 ) * camScale, position.y + ( camHeight / 2 ) * camScale, focusPosition.x, focusPosition.y );
		}
		else {
			show_debug_message( "No focus position defined." );
		}
	}
	
	static GetFocusDisFromCenter = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_distance( position.x + ( camWidth / 2 ) * camScale, position.y + ( camHeight / 2 ) * camScale, focusPosition.x, focusPosition.y );
		}
		else {
			show_debug_message( "No focus position defined." );
		}
	}
	
	static Tick = function() {
		if ( !is_undefined( focusPosition ) ) {
			var _focus_dir = GetFocusDirFromCenter();
			var _focus_dis = GetFocusDisFromCenter();
			
			//position.x = clamp( position.x, position.x, position.x + camBBox.x );
			//position.y = clamp( position.y, position.y, position.y + camBBox.y );
			
			var _width = camera_get_view_width( __camera ) * camScale;
			var _height = camera_get_view_width( __camera ) * camScale;
			var _x = position.x - ( _width  / 2 );
			var _y = position.y - ( _height / 2 );
			
			position.x += dcos( _focus_dir ) * ( camApproachFactor * _focus_dis );
			position.y -= dsin( _focus_dir ) * ( camApproachFactor * _focus_dis );
			
			position.x = median( _width / 2, position.x, camBBox.x - _width / 2 );
			position.y = median( _height / 2, position.y, camBBox.y - _height / 2 );
		}
		
		camApproachFactor *= camScale;
		
		if ( __CAM_DEBUG ) {
			if ( keyboard_check( vk_shift )
			&& mouse_check_button( mb_left ) ) {
				var _mouse_dir = GetMouseDirFromCenter();
	
				position.x += dcos( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
				position.y -= dsin( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
			}
			
			if ( keyboard_check( vk_up ) ) {
				camScale += 0.1;
			}			
			
			if ( keyboard_check( vk_down ) ) {
				camScale -= 0.1;
			}
		}
	}
	
	/// @static
	/// @returns {struct} Vector2( center_x, center_y )
	static GetCameraCenter = function() {
		var _center_x = ( camWidth / 2 ) * camScale;
		var _center_y = ( camHeight / 2 ) * camScale;
		
		return new Vector2( _center_x, _center_y );
	}
	
	/// @static
	/// @returns {struct} Vector2
	static GetCameraResolution = function() {
		return new Vector2( camera_get_view_width( __camera ), camera_get_view_height( __camera ) );
	}
	
	// Draw END
	static DrawOverlay = function() {
		var _center_pos = GetCameraCenter();
		var _x = camera_get_view_x( __camera );
		var _y = camera_get_view_y( __camera );
		
		draw_set_color( c_lime );
		draw_circle( _x + _center_pos.x, _y + _center_pos.y, 2, false );
		draw_text( _x + _center_pos.x, _y + _center_pos.y + 8, "__camera Center" );
		draw_set_color( c_white );
		
		draw_set_color( c_lime );
		draw_rectangle( _x, _y, _x + ( camWidth * camScale ), _y + ( camHeight * camScale ), true );
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
		
		var _center_pos = GetCameraCenter();
		
		camera_set_view_size( __camera, ( camWidth * camScale ), ( camHeight * camScale ) );
		camera_set_view_pos( __camera, position.x, position.y );
		
		gpu_set_zwriteenable( true );
		gpu_set_ztestenable( false );
		
		camWidth = clamp( camWidth, __GAME_WIDTH / 2, __GAME_WIDTH );
		camHeight = clamp( camHeight, __GAME_HEIGHT / 2, __GAME_HEIGHT );
		camAngle = clamp( camAngle, -360, 360 );
		camScale = clamp( camScale, 1, camMaxScale );
		
		camera_set_view_angle( __camera, camAngle );
		camera_apply( __camera );
		
		draw_set_valign( fa_top );
		draw_set_halign( fa_left );
	}
	
	static DrawDebug = function() {
		var _res = GetCameraResolution();
		
		if ( __CAM_DEBUG ) {
			draw_set_color( c_lime );
			draw_text_transformed( position.x + 1, position.y, string( "__camera Resolution:{0} x {1}", _res.x, _res.y ), camScale, camScale, 0 );
			draw_text_transformed( position.x + 1 * camScale, position.y + 20 * camScale, string( "__camera Aspect:{0}", camAspectRatio ), camScale, camScale, 0 );
			
			draw_text_transformed( position.x + 1 * camScale, position.y + 40 * camScale, string( "Display Resolution:{0} x {1}", resolution_manager().displayWidth, resolution_manager().displayHeight ), camScale, camScale, 0 );
			draw_text_transformed( position.x + 1 * camScale, position.y + 60 * camScale, string( "Display Aspect:{0}", resolution_manager().aspectRatio ), camScale, camScale, 0 );
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