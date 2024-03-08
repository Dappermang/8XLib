/// @desc An Animation Player. Intended for use in individual instances/objects.
function cAnimationPlayer() constructor {
    currentAnimation = undefined;
    currentAnimationIndex = 0;
    currentAnimationLength = 0;
    playbackSpeed = 0;
    IsPlaying = false;

    #region Private
    __animationQueue = ds_queue_create();
    
    /// @param {cAnimoAnimation} animation
    static EvaluateEnterCondition = function( animation ) {
        var _enterBoolsSize = array_length( animation.enterConditions );
        var _passed = 0;
        var _result = true;
        
        // Checking if all the Enter conditions passed ...
        if ( _enterBoolsSize > 0 ) {
        	for( var i = 0; i < _enterBoolsSize; ++i ) {
        		if ( animation.enterConditions[i]() ) {
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
    	var _queueHead = ds_queue_head( __animationQueue );

    	if ( EvaluateEnterCondition( _queueHead ) ) {
    		currentAnimation = _queueHead;
    	}
    	else {
    		return;
    	}
    	
        if ( !is_undefined( currentAnimation ) ) {
            
            var _animationFrameCount = currentAnimation.GetFrameAmount();
            
            currentAnimationIndex = max( 0, currentAnimationIndex + currentAnimation.animSpeed );

            if ( floor( currentAnimationIndex ) >= _animationFrameCount ) {
                switch( currentAnimation.animType ) {
                    case ANIMO_TYPE.FINITE :
                    	// Dequeue the current animation...
                    	if ( ds_queue_size( __animationQueue ) > 1 ) {
                    		ds_queue_dequeue( __animationQueue );
                    	}
                        break;
                    case ANIMO_TYPE.CHAINED :
                    	// If we have reached the amount of set repeats and there is a valid animation to change to, we will switch
                        if ( currentAnimation.repeatsCompleted >= currentAnimation.repeats ) {
                    		currentAnimation.ResetIterations();
                    		if ( ds_queue_size( __animationQueue ) > 1 ) {
                    			ds_queue_dequeue( __animationQueue );
                    		}
                        }
                        break;
                }
                
                if ( currentAnimation.repeatsCompleted < currentAnimation.repeats ) {
                    ++currentAnimation.repeatsCompleted;
                }
                
                OnAnimationChanged();
	        }
        }
        else {
        	return;
        }
    }
    static DrawAnimation = function( _x, _y, _xscale = 1, _yscale = 1, _angle = 0, _blend = c_white, _alpha = 1 ) {
    	if ( !is_undefined( currentAnimation ) ) {
    		var _position = { x : _x, y : _y };
    		var _sprite = currentAnimation.GetSprite();
    		
    		draw_sprite_ext( _sprite, currentAnimationIndex, _position.x, _position.y, _xscale, _yscale, _angle, _blend, _alpha );
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
    
    /// @desc Queues an animation, if there are none present it will immediately start playing it, otherwise it will be queued and play after the current one is finished.
    /// @param {struct} animation
    /// @param {bool} overrideCurrent Overrides the current animation regardless of any enterConditions attached.
    static PlayAnimation = function( animation, overrideCurrent = false ) {
        if ( overrideCurrent ) {
            ds_queue_dequeue( __animationQueue );
            ds_queue_enqueue( __animationQueue, animation );
        }
        else {
        	ds_queue_enqueue( __animationQueue, animation );
        }
        
        print( $"Queued : {animation}" );
        
        return self;
    }
    // static GetNextAnimation = function() {
    //     if ( !ds_queue_empty( __animationQueue ) ) {
    //         var _queueSize = ds_queue_size( __animationQueue );
            
    //         for( var i = 0; i < _queueSize; ++i ) {
    //             if ( i <= _queueSize - 1 ) {
    //                 return __animationQueue[| i];
    //                 break;
    //             }
    //         }
    //     }
    // }
    // User Defined.
    static OnAnimationChanged = function() {};
    static GetAnimation = function() {
    	if ( !is_undefined( currentAnimation ) ) {
    		return currentAnimation;
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
        ds_queue_clear( __animationQueue );
        ds_queue_destroy( __animationQueue );
    }
    
    return self;
}