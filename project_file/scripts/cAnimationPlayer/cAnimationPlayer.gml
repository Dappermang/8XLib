/// @desc An Animation Player. Intended for use in individual instances/objects.
/// @param {bool} ?startPaused
function cAnimationPlayer( _startPaused = false ) constructor {
    IsPlaying = false;
    
    if ( _startPaused ) {
    	Pause();
    }

    #region Private
    __animationQueue = ds_list_create();
    __currentAnimation = undefined;
    __currentAnimationIndex = 0;
    __currentAnimationLength = 0;
    
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
        		
        		if ( _passed >= _enterBoolsSize ) {
        			break;
        		}
        	}
        }
        
        return _result;
    }
    // Do not modify this.
    static Tick = function() {
    	var _queueSize = ds_list_size( __animationQueue );
    	var _nextAnimation = GetNextAnimation();
    	
        if ( IsPlaying 
        && !is_undefined( __currentAnimation ) ) {
            var _animationFrameCount = __currentAnimation.GetFrameAmount();
            
            __currentAnimationIndex = max( 0, __currentAnimationIndex + __currentAnimation.animSpeed );

            if ( floor( __currentAnimationIndex ) >= _animationFrameCount ) {
                switch( __currentAnimation.animType ) {
                    case ANIMO_TYPE.FINITE :
                    	// Dequeue the current animation...
                    	if ( _queueSize > 1 ) {
                    		DequeueAnimation();
                    	}
                        break;
                    case ANIMO_TYPE.CHAINED :
                    	// If we have reached the amount of set repeats and there is a valid animation to change to, we will switch
                        if ( __currentAnimation.repeatsCompleted >= __currentAnimation.repeats ) {
                    		__currentAnimation.ResetIterations();
                    		if ( _queueSize > 1 ) {
                    			DequeueAnimation();
                    		}
                        }
                        break;
                }
                
                if ( __currentAnimation.repeatsCompleted < __currentAnimation.repeats ) {
                    ++__currentAnimation.repeatsCompleted;
                }
                
                if ( !is_undefined( _nextAnimation ) 
                && __evaluateEnterCondition( _nextAnimation ) ) {
                	__currentAnimation = _nextAnimation;
                }
    	         
    	        OnAnimationChanged();
	        }
        }
        else {
        	return;
        }
    }
    static DrawAnimation = function( _x, _y, _xscale = 1, _yscale = 1, _angle = 0, _blend = c_white, _alpha = 1 ) {
    	if ( !is_undefined( __currentAnimation ) ) {
    		var _position = { x : _x, y : _y };
    		var _sprite = __currentAnimation.GetSprite();
    		
    		draw_sprite_ext( _sprite, __currentAnimationIndex, _position.x, _position.y, _xscale, _yscale, _angle, _blend, _alpha );
    	}
    	else {
    		return;
    	}
    }
    #endregion
    
    #region User Callbacks
    /// @desc User Defined. Invoked when ANY animation exits the queue.
    static OnAnimationFinished = function(){};
    /// @desc User Defined. Invoked when ANY animation exits the queue.
    static OnAnimationExitQueue = function(){};
    #endregion
    /// @desc Queues an animation or an array of animations. If there are none present it will immediately start playing it, otherwise it will be queued and play after the current one is finished.
    /// @param {struct|array[struct]} animation
    /// @param {bool} ?overrideCurrent Overrides the current animation regardless of any enterConditions attached.
    static PlayAnimation = function( animation, overrideCurrent = false ) {
        if ( overrideCurrent ) {
            ds_list_delete( __animationQueue, 0 );
            ds_list_add( __animationQueue, animation );
        }
        else {
        	ds_list_add( __animationQueue, animation );
        }
        
        __currentAnimation = __animationQueue[| 0];
        
        print( $"Queued : {animation}" );
        
        return self;
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
    // User Defined.
    static OnAnimationChanged = function() {};
    static DequeueAnimation = function() {
    	ds_list_delete( __animationQueue, 0 );
    }
    static GetAnimation = function() {
    	if ( !is_undefined( __currentAnimation ) ) {
    		return __currentAnimation;
    	}
    }
    static GetQueue = function() {
        return __animationQueue;
    }
    static ClearQueue = function() {
        ds_queue_clear( __animationQueue );
        return self;
    }
    static Play = function() {
        IsPlaying = true;
        return self;
    }    
    static Pause = function() {
        IsPlaying = false;
        return self;
    }
    static Cleanup = function() {
        ds_list_clear( __animationQueue );
        ds_list_destroy( __animationQueue );
    }
    
    return self;
}