function cAnimoAnimation() constructor {
    sprite = sprGuy;
    frames = [];
    animSpeed = 0.1;
    animType = ANIMO_TYPE.FINITE;
    /* 
        These 2 variables are arrays of bool-evaluating functions. Whenever a sequence needs to 'enter' a new animation in the sequence, it will parse for
        an enter condition. If the result is false, it will not advance the sequence and will instead animate 
        depending on whatever the animation type is until the expression evaluates to true. Same logic applies for EXIT conditions
        
        enterConditions
        exitConditions
    */
    enterConditions = [];
    exitConditions = [];
    repeats = 0;
    repeatsCompleted = 0;
    
    Init();
    
	// Populating the frame array with all sprite frames
	static Init = function() {
		var _imageCount = sprite_get_number( sprite );
		
		for( var i = 0; i < _imageCount; ++i ) {
			frames[i] = [i];
		}
	}
	
	static GetSprite = function() {
		if ( !is_undefined( sprite ) ) {
			return sprite;	
		}
		else {
			return __animoFallbackSprite;
		}
	}
	static GetFrameAmount = function() {
		return array_length( frames );
	}
	
	static AddEnterCondition = function( conditionFunc ) {
	    if ( !is_callable( conditionFunc ) ) {
	        return;
	    }
	    
	    array_push( enterConditions, conditionFunc );
	}	
	static AddExitCondition = function( conditionFunc ) {
	    if ( !is_callable( conditionFunc ) ) {
	        return;
	    }
	    
	    array_push( exitConditions, conditionFunc );
	}
	static SetSprite = function( _sprite ) {
		sprite = _sprite;
		return self;
	}
	
	return self;
}

function cAnimoSequence() constructor {
    paused = false;
    animationIndex = 0; // the index of the current animation we are on
    animations = []; // array of animations to be played within the sequence
    
    repeats = 0;
    repeatsCompleted = 0;
    
    // ugh...
    static Tick = function() {
    	var _currentAnimation = animations[animationIndex];
        
        var index = scope[$ variable_name] + _currentAnimation.animSpeed;
        var _frameCount = array_length( _currentAnimation.frames );
        
        // Frame callbacks
        if ( index >= 0
        && index < _frame_count ) {
            if ( !is_undefined( scope[$ _currentAnimation].frames[index][1] ) ) {
                // Only execute callback if it has not already been called.
                if ( !scope[$ _currentAnimation].frames[index][2] ) {
                    scope[$ _currentAnimation].frames[index][1]();
                    scope[$ _currentAnimation].frames[index][2] = true;
                }
            }
        }
        
        if ( floor( index ) >= array_length( scope[$ _currentAnimation].frames ) ) {
            switch( scope[$ _currentAnimation].animType ) {
                case ANIMO_TYPE.FINITE :
                	// Switch back to the start index and stop animating
                	index = 0;
                	scope[$ _currentAnimation].animSpeed = 0;
                    break;
                case ANIMO_TYPE.CHAINED :
                	// If we have reached the amount of set repeats and there is a valid animation to change to, we will switch
                    if ( ( scope[$ _currentAnimation].currentIterations >= scope[$ _currentAnimation].animRepeats )
                    && !is_undefined( scope[$ _currentAnimation].animNext ) ) {
                		scope[$ _currentAnimation].ResetIterations();
                		scope[$ _currentAnimation].OnAnimationSwitch();
                		scope[$ _currentAnimation] = scope[$ _currentAnimation].animNext;
                		index = 0;
                    }
                    // If there is no animation to switch to, just start looping, but don't change type because we may want to set this later.
                    else if ( is_undefined( scope[$ _currentAnimation].animNext ) ) {
                		index = 0;
                		scope[$ _currentAnimation].ResetIterations();
                		scope[$ _currentAnimation].OnAnimationSwitch();
                    }
                    break;
            }
            
            // If there is no end index available, we will just execute the function now
            if ( !is_undefined( scope[$ _currentAnimation].animEndCallback ) ) {
                scope[$ _currentAnimation].animEndCallback();
            }
            
            index = 0;
         	
            if ( scope[$ _currentAnimation].currentIterations < scope[$ _currentAnimation].animRepeats ) {
                ++scope[$ _currentAnimation].currentIterations;
            }
            
            // Reset all callbacks so they can be called again
            scope[$ _currentAnimation].RefreshCallbacks();
	    }
	    
	    scope[$ variable_name] = clamp( index, 0, _frame_count );
    }
    static OnSequenceEnd = function() {}
    static AnimationHasEnterCondition = function() {
        var _result = false;
        
        if ( array_length( currentAnimation.enterConditions ) > 0 ) {
            _result = true;
        }
        
        return _result;
    }    
    static AnimationHasExitCondition = function() {
        var _result = false;
        
        if ( array_length( currentAnimation.exitConditions ) > 0 ) {
            _result = true;
        }
        
        return _result;
    }
    /// @param {struct} animation
    /// @param {array[function]} ?conditions
    static AddAnim = function( animation, _conditions = [] ) {
		if ( !is_undefined( _conditions ) ) {
	    	for( var i = 0; i < array_length( _conditions ); ++i ) {
	    		if ( !is_callable( _conditions[i] ) ) {
	    			show_error( $"One or more conditions were not a valid function!", true );
	    		}
	    		
	    		animation.AddEnterCondition( _conditions[i] );
			}
		}
    	
        array_push( animations, animation );
        return self;
    } 
    /// @param {struct} animation
    /// @param {int} loop count
    /// @param {array[function]} ?conditions
    static AddLoop = function( animation, _loopAmount = -1, _conditions = [] ) {
    	animation.SetAnimType( ANIMO_TYPE.LOOPED );
    	animation.SetRepeats( ( _loopAmount > -1 ) ? 0 : _loopAmount );
    	
		if ( !is_undefined( _conditions ) ) {
	    	for( var i = 0; i < array_length( _conditions ); ++i ) {
	    		if ( !is_callable( _conditions[i] ) ) {
	    			show_error( $"One or more conditions were not a valid function!", true );
	    		}
	    		
	    		animation.AddEnterCondition( _conditions[i] );
			}
		}
    	
        array_push( animations, animation );
        return self;
    }
    static Pause = function() {
        paused = true;
    }
    static Unpause = function() {
        paused = false;
    }
    static Stop = function() {
        animationIndex = array_length( animations ) - 1;
        Pause();
    }
    
    return self;
}

function testSequence() {
	testCondition = function() {
		return true;
	}
	
    animation = new cAnimoAnimation();
    
    animationSequence = new cAnimoSequence()
    .AddAnim( animation, [testCondition] )
    .AddLoop( animation, 0, [testCondition] );
}