/// @self {cAnimo|function}
function cAnimo() constructor {
    self.sprite = -1; // Asset index of the sprite
    self.frames = [];
    self.currentIterations = 0; // How many times we already have looped.
	self.animRepeats = 0; // How many times we will loop.
    self.animNext = undefined; // Struct reference of next animation.
    self.animType = ANIMO_TYPE.FINITE;
    self.animSpeed = 0;
    self.animStartIndex = 0;
    
    // End frame defined to execute the end function. If none is defined then it will execute at the end of an animation
    self.animEndIndex = 0;
    self.animEndCallback = undefined;
	
	static AnimationHasEnded = function( result ) {
		return result;
	}
	
	#region Getters
	/// @static
	static GetSprite = function() {
		return self.sprite;
	}	
	/// @static
	static GetAnimSpeed = function() {
		return self.animSpeed;
	}
	/// @static
	static GetAnimType = function() {
		return self.animType;
	}
	/// @static
	static GetRepeats = function() {
		return self.animRepeats;
	}
	/// @static
	static GetFrameCallback = function( _frame = 0 ) {
		if ( self.frames[_frame][1] ) {
			return self.frames[_frame][1];
		}
		else {
			show_debug_message( $"Could not find callback on frame {_frame}." );
		}
	}
	#endregion
	#region Setters
	/// @static
	/// @param {number} _frame
	/// @param {function} callback
	static SetFrameCallback = function( frame, callback ) {
		 self.frames[frame][1] = method( undefined, callback );
	}
	
	/// @static
	/// @param {function} callback
	static SetAnimEndCallback = function( callback ) {
		self.animEndCallback = method( undefined, callback );
	}

	/// @static
	static OnAnimationSwitch = function() {
		self.currentIterations = 0;
	}
	
	/// @static
	/// @param {number} anim_speed
	static SetAnimSpeed = function( anim_speed ) {
		self.animSpeed = anim_speed;
	}
	
	/// @static
	/// @param {number} type
	static SetAnimType = function( type ) {
		self.animType = type;
	}
	
	/// @static
	/// @param {number} type
	static SetSprite = function( sprite ) {
		if ( !sprite_exists( sprite ) ) {
			show_error( $"{sprite} is not an existing sprite!", true );
		}
		
		self.sprite = sprite;
	}
	#endregion
	
	/// @static
	static SetRepeats = function( repeats ) {
		self.animRepeats = repeats;
	}
	
	/// @static
	static ResetIterations = function() {
		self.currentIterations = 0;
	}
	
	// Populating the frame array with all sprite frames
	static Init = function() {
		var _image_count = sprite_get_number( self.sprite );
		
		for( var i = 0; i < _image_count; ++i ) {
			self.frames[i] = [i, undefined, false];
		}
	}
	
	static RefreshCallbacks = function() {
	// Iterating over every frames callback and setting them back to false so they can be invoked.
		var _frame_count = array_length( self.frames );
		
		for( var i = 0; i < _frame_count; ++i ) {
			self.frames[i][2] = false;
		}
	}
}