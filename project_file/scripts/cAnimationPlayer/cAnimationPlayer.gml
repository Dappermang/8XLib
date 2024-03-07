/// @desc An Animation Player. Intended for use in individual instances/objects.
function cAnimationPlayer() constructor {
    currentAnimation = undefined;
    currentAnimationIndex = 0;
    currentAnimationLength = 0;
    playbackSpeed = 0;
    IsPlaying = false;
    
    #region Private
    __animationQueue = ds_queue_create();
    
    static __tick = function() {
        if ( !is_undefined( currentAnimation ) ) {
            currentAnimation = ds_queue_head( __animationQueue );
            
            var _animationFrameCount = currentAnimation.GetFrameAmount();
            
            currentAnimationIndex = clamp( currentAnimationIndex, 0, _animationFrameCount );
            
            var index = scope[$ variable_name] + currentAnimation.animSpeed;
            
            if ( floor( index ) >= _animationFrameCount ) {
                switch( scope[$ currentAnimation].animType ) {
                    case ANIMO_TYPE.FINITE :
                    	// Switch back to the start index and stop animating
                    	index = 0;
                    	scope[$ currentAnimation].animSpeed = 0;
                        break;
                    case ANIMO_TYPE.CHAINED :
                    	// If we have reached the amount of set repeats and there is a valid animation to change to, we will switch
                        if ( ( scope[$ currentAnimation].currentIterations >= scope[$ currentAnimation].animRepeats )
                        && !is_undefined( scope[$ currentAnimation].animNext ) ) {
                    		scope[$ currentAnimation].ResetIterations();
                    		scope[$ currentAnimation] = scope[$ currentAnimation].animNext;
                    		index = 0;
                        }
                        // If there is no animation to switch to, just start looping, but don't change type because we may want to set this later.
                        else if ( is_undefined( scope[$ currentAnimation].animNext ) ) {
                    		index = 0;
                    		scope[$ currentAnimation].ResetIterations();
                        }
                        break;
                }
                
                index = 0;
             	
                if ( scope[$ currentAnimation].currentIterations < scope[$ currentAnimation].animRepeats ) {
                    ++scope[$ currentAnimation].currentIterations;
                }
	        }
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
    /// @param {bool} overrideCurrent
    static PlayAnimation = function( animation, overrideCurrent = false ) {
        if ( ds_queue_empty( __animationQueue ) ) {
            currentAnimation = animation;
        }
        else if ( overrideCurrent ) {
            ds_queue_dequeue( __animationQueue );
            ds_queue_enqueue( __animationQueue, animation );
        }
        else {
            ds_queue_enqueue( __animationQueue, animation );
        }
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