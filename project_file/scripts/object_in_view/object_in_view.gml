/// @param {instance} target
/// @param {object} ?padding
/// @param {object} ?useSpriteDimensions Whether or not the Targets sprite_index will be used when calculating if it is in view.
function object_in_view( target, _padding = 8, _useSpriteDimensions = false ) {
	if ( instance_exists( target ) ) {
		if ( _useSpriteDimensions ) {
			var _targetSpriteWidth = ( sprite_get_width( target.sprite_index ) / 2 )  ?? 32;
			var _targetSpriteHeight = ( sprite_get_height( target.sprite_index ) / 2 ) ?? 32;
			var _camera = camera_get_active();
			var _cameraViewX = camera_get_view_x( _camera );
			var _cameraViewY = camera_get_view_y( _camera );
			var _cameraWidth = camera_get_view_width( _camera );
			var _cameraHeight = camera_get_view_height( _camera );
		
            if ( target.x + _targetSpriteWidth >= _cameraViewX - ( _cameraWidth / 2 ) - _padding && target.x - _targetSpriteWidth <= _cameraViewX + ( _cameraWidth / 2 ) + _padding
                && target.y + _targetSpriteHeight >= _cameraViewY - ( _cameraHeight / 2 ) - _padding && target.y - _targetSpriteHeight <= _cameraViewY + ( _cameraHeight / 2 ) + _padding ) {
                    return true;
            }
		}
		else {
           if ( target.x >= _cameraViewX - ( _cameraWidth / 2 ) - _padding && target.x <= _cameraViewX + ( _cameraWidth / 2 ) + _padding
                && target.y >= _cameraViewY - ( _cameraHeight / 2 ) - _padding && target.y <= _cameraViewY + ( _cameraHeight / 2 ) + _padding ) {
                    return true;
            }
		}
	}
	else {
	    return false;
	}
}