/// @desc An Animation Player. Intended for use in individual instances/objects.
/// @param {bool} ?startPaused
function cAnimationPlayer( _startPaused = false ) constructor {
    isPlaying = true;
    
    if ( _startPaused ) {
    	Pause();
    }

    #region Private
    __animationQueue = ds_list_create();
    __currentAnimation = __animationQueue[| 0];
    __currentAnimationIndex = 0;
    __currentAnimationLength = 0;
    
    static __animationRepeated = function() {
        if ( is_callable( __currentAnimation.OnRepeat ) ) {
        	__currentAnimation.OnRepeat();
        }
    }   
    static __animationFinished = function() {
        if ( is_callable( __currentAnimation.OnAnimationEnd ) ) {
        	__currentAnimation.OnAnimationEnd();
        }  
    }
    static __evaluateEnterCondition = function( animation ) {
    	var _enterConditions = animation.GetEnterConditions();
        var _enterBoolsSize = array_length( _enterConditions );
        var _passed = 0;
        var _result = true;
        
        // Checking if all the Enter conditions passed ...
        if ( _enterBoolsSize > 0 ) {
        	for( var i = 0; i < _enterBoolsSize; ++i ) {
        		if ( _enterConditions[i]() ) {
        			++_passed;
        		}
        	}
        }
        
        		
        if ( _passed < _enterBoolsSize ) {
        	_result = false;
        }
        
        return _result;
    }    
    static __evaluateExitCondition = function( animation ) {
    	var _exitConditions = animation.GetExitConditions();
        var _exitBoolsSize = array_length( _exitConditions );
        var _passed = 0;
        var _result = true;
        
        // Checking if all the Enter conditions passed ...
        if ( _exitBoolsSize > 0 ) {
        	for( var i = 0; i < _exitBoolsSize; ++i ) {
        		if ( _exitConditions[i]() ) {
        			++_passed;
        		}
        	}
        }
        
        if ( _passed < _exitBoolsSize ) {
        	_result = false;
        }
        
        return _result;
    }
	static __finishedRepeats = function() {
		var _result = false;
		
        if ( __currentAnimation.repeatsCompleted >= __currentAnimation.repeats ) {
            _result = true;
        }
		
		return _result;
	}
    
    // Do not modify this.
    static Tick = function() {
    	var _queueSize = ds_list_size( __animationQueue );
    	var _nextAnimation = GetNextAnimation();
    	
        if ( !is_undefined( __currentAnimation ) ) {
            var _animationFrameCount = __currentAnimation.GetFrames();
            var _animationSpeed = __currentAnimation.animSpeed;
            
            __currentAnimationIndex += _animationSpeed;
            
            if ( floor( __currentAnimationIndex + _animationSpeed ) >= _animationFrameCount ) {
                if ( __currentAnimation.repeatsCompleted < __currentAnimation.repeats ) {
                	__animationRepeated();
                    print( __currentAnimation.repeatsCompleted );
                    ++__currentAnimation.repeatsCompleted;
                }
                // Reset Animation Index
                __animationFinished();
                __currentAnimationIndex = 0;
                
                if ( __currentAnimation.repeats != -1 ) {
                    // Dequeue the current animation...
                    if ( __finishedRepeats() ) {
                    	// If we have a next animation, can Enter it, and can Exit the current one...
                        if ( !is_undefined( _nextAnimation ) 
                        && __evaluateEnterCondition( _nextAnimation )
                        && __evaluateExitCondition( __currentAnimation ) ) {
                    		if ( _queueSize > 1 ) {
                    			// Rest Repeats
                        		__currentAnimation.ResetRepeats();
                        		// Dequeue
                    			DequeueAnimation();
                    			// Set the current to the next!
                    			__currentAnimation = _nextAnimation;
                    		}
                        }
	                }
                }
            }
        }
    }
    #endregion
    #region User Methods
    static DrawAnimation = function( _x, _y, _xscale = 1, _yscale = 1, _angle = 0, _blend = c_white, _alpha = 1 ) {
    	var _sprite = __currentAnimation.GetSprite();
    	
    	if ( sprite_exists( _sprite ) ) {
    		var _position = { x : _x, y : _y };
    		
    		draw_sprite_ext( _sprite, __currentAnimationIndex, _position.x, _position.y, _xscale, _yscale, _angle, _blend, _alpha );
    	}
    	else {
    		return;
    	}
    }
    static DequeueAnimation = function() {
    	ds_list_delete( __animationQueue, 0 );
    }
    static ClearQueue = function() {
        ds_list_clear( __animationQueue );
        return self;
    }
    static Play = function() {
        isPlaying = true;
        return self;
    }    
    static Pause = function() {
        isPlaying = false;
        return self;
    }
    static Cleanup = function() {
        ds_list_clear( __animationQueue );
        ds_list_destroy( __animationQueue );
    }
    #region Get
    static GetCurrentAnimation = function() {
    	if ( !is_undefined( __currentAnimation ) ) {
    		return __currentAnimation;
    	}
    }
    static GetQueue = function() {
        return __animationQueue;
    }
    static AnimationIsPlaying = function( animationName ) {
    	var _result = false;
    	
    	if ( __currentAnimation == animationName ) {
    		_result = true;
    	}
    	
    	return _result;
    }
    static GetNextAnimation = function() {
        var _queueSize = ds_list_size( __animationQueue );
        var _nextAnimation = undefined;
    
        if ( _queueSize > 0 ) {
            for( var i = 0; i < _queueSize; ++i ) {
                if ( i <= _queueSize - 1 ) {
                    _nextAnimation = __animationQueue[| i + 1];
                    break;
                }
            }
        }
        
        return _nextAnimation;
    }
    #endregion
    #region Set
    /// @desc Queues an animation or an array of animations. If there are none present it will immediately start playing it, otherwise it will be queued and play after the current one is finished.
    /// @param {struct|array[struct]} animation
    /// @param {bool} ?overrideCurrent Overrides the current animation regardless of any enterConditions attached.
    static QueueAnimation = function( animation, overrideCurrent = false ) {
    	if ( is_array( animation ) ) {
    		var _argCount = array_length( animation );
    		
    		for( var i = 0; i < _argCount; ++i ) {
    			var _argument = animation[i];

        		ds_list_add( __animationQueue, _argument );
        		print( $"Queued : {_argument}" );
    		}
    	}
        else {
        	ds_list_add( __animationQueue, animation );
        	print( $"Queued : {animation}" );
    	}
    	
    	if ( overrideCurrent ) {
    		ClearQueue();
    	}
    	
    	__currentAnimation = __animationQueue[| 0];
        
        return self;
    }
    #endregion
    #endregion
    
    return self;
}