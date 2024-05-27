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
			call_later( 10, time_source_units_frames, initWindow, false );
		}
	}
	
	/// @static
	/// @param {enum_tuple} mode
	static ChangeResMode = function( mode ) {
		__WINDOW_MODE = mode;
		updateResolution = true;
	}
}