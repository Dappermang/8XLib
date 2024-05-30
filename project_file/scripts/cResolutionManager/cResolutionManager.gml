function resolution_manager() {
	static sClass = new cResolutionManager();
	return sClass;
}

function cResolutionManager() constructor {
	totalCameras = 0;
	currentCamera = undefined;
	
	gameResWidth = __GAME_RES_WIDTH;
	gameResHeight = __GAME_RES_HEIGHT;
	
	windowWidth = window_get_width();
	windowHeight = window_get_height();
	
	displayWidth = display_get_width();
	displayHeight = display_get_height();
	
	displayCenterW = ( displayWidth / 2 ) - ( windowWidth / 2 );
	displayCenterH = ( displayHeight / 2 ) - ( windowHeight / 2 );
	
	windowCenterW = ( windowWidth / 2 );
	windowCenterH = ( windowHeight / 2 );
	
	aspectRatio = gameResWidth / gameResHeight;
	
	// Used for updating res and variables when a change to the game window is made e.x resizing
	updateResolution = false;
	
	static Update = function() {
		if ( updateResolution ) {
			call_later( 10, time_source_units_frames, InitWindow, false );
		}
	}
	
	static InitWindow = function() {
		switch( __WINDOW_MODE ) {
			case RES_MODE.FULLSCREEN:
				window_set_fullscreen( true );
				window_set_size( display_get_width(), display_get_height() );
				window_set_showborder( false );
				break;
			case RES_MODE.WINDOWED:
				window_set_fullscreen( false );
				window_set_size( display_get_width(), display_get_height() );
				window_set_position( 0, 0 );
				window_set_showborder( false );
				break;
			case RES_MODE.BORDERLESS:
				window_set_fullscreen( true );
				window_set_showborder( false );
				break;
		}
		
		updateResolution = false;
	}
	
	/// @static
	/// @param {enum_tuple} mode
	static ChangeResMode = function( mode ) {
		__WINDOW_MODE = mode;
		updateResolution = true;
	}
}