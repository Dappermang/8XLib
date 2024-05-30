function cCameraOrthographic() extends cCamera() class {
	SetProjectionMatrix( __PROJECTION_TYPE.ORTHOGRAPHIC );
	SetViewMatrix();
}
function cCamera() class {
	#region Private
	__camID = 0;
	__camera = -1;
	
	enum __PROJECTION_TYPE {
		ORTHOGRAPHIC,
		PERSPECTIVE
	}
	
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
	camRenderSurface = -1;
	camBBox = new Vector2( room_width, room_height );
	camBBoxSize = 32;// __camera bound box size used for movement
	camAngle = 0;
	camAlignment = 0;
	camResolutionScale = 1;
	camZoomLevel = 1;
	camMaxScale = 8;
	camFov = 90;
	camApproachFactor = 0.0075;// The speed at which the camera will move towards its focus position
	camClipDistanceNear = -3072;
	camClipDistanceFar = 3072;
	camShake = 0;
	camPath = undefined;
	camMovePosition = new Vector2( 0, 0 );
	
	focusPosition = undefined;
	transform = new cTransform3D();
	position = new Vector3( 0, 0, -512 );
	
	projMatrix = matrix_build_projection_ortho( 
		__GAME_RES_WIDTH, __GAME_RES_HEIGHT, 
		camClipDistanceNear, camClipDistanceFar 
	);
	viewMatrix = matrix_build_lookat( 
		position.x, position.y, position.z, 
		position.x + dsin( camAngle ), position.y + dcos( camAngle ), 0, 
		0, 0, 1
	);	
	
    mousePosition = new Vector2(
        mouse_x - camera_get_view_x( __camera ),
        mouse_y - camera_get_view_y( __camera ) 
    );
	// Animation curves used for 'zoom' and 'shake' FX
	zoomCurve = undefined;
	shakeCurve = undefined;
	#endregion
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
		return point_direction( position.x, position.y, mouse_x, mouse_y );
	}
	
	static GetMouseDisFromCenter = function() {
		return point_distance( position.x, position.y, mouse_x, mouse_y );
	}
	
	static GetFocusDirection = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_direction( position.x, position.y, focusPosition.x, focusPosition.y );
		}
		else {
			show_debug_message( "No focus position defined." );
		}
	}
	static GetFocusDistance = function() {
		if ( !is_undefined( focusPosition ) ) {
			return point_distance( position.x, position.y, focusPosition.x, focusPosition.y );
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
		var _center_x = position.x - ( camWidth / 2 ) * camZoomLevel;
		var _center_y = position.y - ( camHeight / 2 ) * camZoomLevel;
		
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
	static SetProjectionMatrix = function( _type = __PROJECTION_TYPE.ORTHOGRAPHIC ) {
		switch( _type ) {
			case __PROJECTION_TYPE.ORTHOGRAPHIC :
				projMatrix = matrix_build_projection_ortho( 
					__GAME_RES_WIDTH, __GAME_RES_HEIGHT, 
					camClipDistanceNear, camClipDistanceFar 
				);
				break;			
			case __PROJECTION_TYPE.PERSPECTIVE :
				projMatrix = matrix_build_projection_perspective_fov( 
					camFov, GetAspectRatio(),
					camClipDistanceNear, camClipDistanceFar 
				);
				break;
		}
	}
	static SetViewMatrix = function( _xUp = 0, _yUp = 0, _zUp = 1 ) {
		var _targetX = position.x + dsin( camAngle );
		var _targetY = position.y + dcos( camAngle );
	
		viewMatrix = matrix_build_lookat( 
			position.x, position.y, position.z, 
			_targetX, _targetY, 0, 
			_xUp, _yUp, _zUp
		);
	}
	static SetWidth = function( width ) {
		camWidth = width;
		camera_apply( self.__camera );
		return self;
	}	
	static SetHeight = function( height ) {
		camHeight = height;
		camera_apply( self.__camera );
		return self;
	}
	static SetBoundaries = function( width, height ) {
		camBBox.x = width;
		camBBox.y = height;
		return self;
	}
	static SetPath = function( path ) {
		if ( !path_exists( path ) ) {
			print( $"Could not set path." );
		}
		
		camPath = path;
		return self;
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
	/// @param {number|instance} x
	/// @param {number} ?y
	/// @param {number} ?z
	/// @param {bool} ?instant
	static SetFocusPosition = function( _x, _y = _x, _z = 0, _instant = false ) {
		if ( instance_exists( _x ) ) {
			focusPosition = new Vector3( _x.x, _x.y, _z );
		}
		else {
			focusPosition = new Vector3( _x, _y, _z );
		}
		
		if ( _instant ) {
			position = focusPosition;
		}
		return self;
	}
	static SetFocusPositionAligned = function( _x, _y, _z = 0, align = CAM_ALIGN.MIDDLE ) {
		// focusPosition = new Vector3( _x, _y, _z );
		
		// switch( align ) {
		// 	case CAM_ALIGN.MIDDLE :// Middle
		// 		// camAlignment = 0;
		// 		break;			
		// 	case CAM_ALIGN.LEFT :// Left
		// 		// camAlignment = point_direction( _x - ( camWidth / 2 ), _y,  _x - ( camWidth / 2 ), _y );
		// 		focusPosition = new Vector3( _x - ( camWidth / 2 ), _y, _z );
		// 		break;			
		// 	case CAM_ALIGN.RIGHT : // Right
		// 		focusPosition = new Vector3( _x + ( camWidth / 2 ), _y, _z );
		// 		break;			
		// 	case CAM_ALIGN.TOP : // Top
		// 		focusPosition = new Vector3( _x, _y - ( camHeight / 2 ), _z );
		// 		break;			
		// 	case CAM_ALIGN.BOTTOM : // Bottom
		// 		focusPosition = new Vector3( _x, _y + ( camHeight / 2 ), _z );
		// 		break;
		// }
		// return self;
	}
	#endregion
	// add functionality for putting a camera on a track
	/* 
	     camera.SetPath( path )
	     
	     > iterate through path points ?
	     camera.SetPathSpeed( speed ) <- This would ideally be tied to player speed
	     
	*/
	static TickBegin = function() {};
	static Tick = function() {
    	mousePosition = GetMousePosition();
		// camMovePosition = position;
		
		var _camSize = GetSize();
		
		if ( !is_undefined( focusPosition ) ) {
			var _focusDir = GetFocusDirection();
			var _focusDis = GetFocusDistance();
			
			position.x += dcos( _focusDir ) * ( camApproachFactor * _focusDis );
			position.y -= dsin( _focusDir ) * ( camApproachFactor * _focusDis );
		}
		
		position.x = median( _camSize.x / 2, position.x, camBBox.x - _camSize.x / 2 );
		position.y = median( _camSize.y / 2, position.y, camBBox.y - _camSize.y / 2 );
		
		if ( !is_undefined( camPath ) ) {
			var _pathLength = path_get_length( camPath );
			var _pathStartPoint = new Vector2( path_get_point_x( camPath, 0 ), path_get_point_y( camPath, 0 ) );
			var _pathEndPoint = new Vector2( path_get_point_x( camPath, _pathLength - 1 ), path_get_point_y( camPath, _pathLength - 1 ) );
			var _currentPoint = 0;
			var _pathCurrentPoint = new Vector2( path_get_point_x( camPath, _currentPoint ), path_get_point_y( camPath, _currentPoint ) );
			var _pointDirection = point_direction( position.x, position.y, _pathCurrentPoint.x, _pathCurrentPoint.y );
			
			if ( _currentPoint < _pathLength ) {
				position.x += dcos( _pointDirection ) * ( camApproachFactor );
				position.y -= dsin( _pointDirection ) * ( camApproachFactor );
				++_currentPoint;
			}
		}
		
		// camApproachFactor *= camZoomLevel;
		
		if ( __CAM_DEBUG ) {
			if ( mouse_check_button_pressed( mb_middle ) ) {
				SetFocusPosition( objAnimationTest, 0, 0, false );
			}
			if ( !is_undefined( focusPosition )
			&& mouse_check_button_pressed( mb_right ) ) {
				ClearFocus();
			}
			
			var _mouseWheel = keyboard_check( vk_down ) - keyboard_check( vk_up );
			
			if ( keyboard_check( vk_shift )
			&& mouse_check_button( mb_left ) ) {
				var _mouse_dir = GetMouseDirFromCenter();
	
				position.x += dcos( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
				position.y -= dsin( _mouse_dir ) * max( 3, GetMouseDisFromCenter() * 0.05 );
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
	static TickEnd = function() {
		camera_set_view_pos( __camera, position.x - ( camWidth * camZoomLevel ) / 2, position.y - ( camHeight * camZoomLevel ) / 2 );
		camera_set_view_size( __camera, camWidth * camZoomLevel, camHeight * camZoomLevel );
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
		draw_rectangle( _x, _y, _x + ( camWidth * camZoomLevel ), _y + ( camHeight * camZoomLevel ), true );
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
			if ( !is_undefined( focusPosition ) ) {
				draw_sprite( __spr_animo_fallback, -1, focusPosition.x, focusPosition.y );
				
				var _focusDir = GetFocusDirection();
			
				draw_arrow( position.x, position.y, position.x + lengthdir_x( 16, _focusDir ), position.y + lengthdir_y( 16, _focusDir ), 8 );
			}
			draw_set_color( c_white );
			
			draw_circle( mouse_x, mouse_y, 1, true );
			draw_circle( position.x, position.y, 2, true );
			
			draw_set_color( make_color_rgb( 90, 90, 90 ) );
			draw_rectangle( 0, 0, room_width, room_height, true );
			draw_set_color( c_aqua );
			draw_circle( camMovePosition.x, camMovePosition.y, 2, true );
			draw_rectangle( position.x - camBBox.x, position.y - camBBox.y, position.x + camBBox.x, position.y + camBBox.y, true );
			draw_set_color( c_white );
			
			draw_text( room_width / 2, room_height / 2, "Room Center" );
			draw_circle( room_width / 2, room_height / 2, 2, true );
		}
	}
	return self;
}