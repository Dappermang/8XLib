function cAnimoData() constructor {
    sprite = -2;
    animSpeed = 0.1;
    repeats = 0;
    repeatsCompleted = 0;
    stopOnEnd = false;
    
    OnAnimationEnd = -1;
    OnRepeat = -1;
    
    #region Private
    __frames = [];
    __enterConditions = [];
    __exitConditions = [];
    
	// Populating the frame array with all sprite frames
	static __init = function() {
		var _imageCount = sprite_get_number( sprite );
		
		for( var i = 0; i < _imageCount; ++i ) {
			__frames[i] = [i];
		}
	}
	#endregion
	#region Get
	static GetEnterConditions = function() {
		return __enterConditions;
	}	
	static GetExitConditions = function() {
		return __exitConditions;
	}
	static GetSprite = function() {
		if ( !is_undefined( sprite ) ) {
			return sprite;	
		}
		else {
			return __animoFallbackSprite;
		}
	}
	static GetFrames = function() {
		return array_length( __frames );
	}
	#endregion
	#region Set
	static SetSprite = function( _sprite ) {
		sprite = _sprite;
		__init();
		return self;
	}	
	static SetSpeed = function( _speed ) {
		animSpeed = _speed;
		return self;
	}
	static SetRepeats = function( _amount = 0 ) {
		repeats = _amount;
		return self;
	}
	static SetAnimationEnd = function( _animationEnd ) {
		OnAnimationEnd = _animationEnd;
		return self;
	}	
	static SetOnRepeat = function( _animationEnd ) {
		OnRepeat = _animationEnd;
		return self;
	}
	static StopOnEnd = function( _stop = false ) {
		stopOnEnd = _stop;
		return self;
	}
	static ResetRepeats = function() {
		repeatsCompleted = 0;
	}
	static AddEnterCondition = function( conditionFunc ) {
	    if ( !is_callable( conditionFunc ) ) {
	        return;
	    }
	    
	    array_push( __enterConditions, conditionFunc );
	    return self;
	}	
	static AddExitCondition = function( conditionFunc ) {
	    if ( !is_callable( conditionFunc ) ) {
	        return;
	    }
	    
	    array_push( __exitConditions, conditionFunc );
	    return self;
	}
	#endregion
	
	return self;
}

function cAnimoSequence() constructor {
    paused = false;
    animationIndex = 0; // the index of the current animation we are on
    animations = []; // array of animations to be played within the sequence
    
    repeats = 0;
    repeatsCompleted = 0;
    
    static OnSequenceEnd = function() {};
    static AnimationHasEnterCondition = function() {
        var _result = false;
        
        if ( array_length( __enterConditions ) > 0 ) {
            _result = true;
        }
        
        return _result;
    }    
    static AnimationHasExitCondition = function() {
        var _result = false;
        
        if ( array_length( __exitConditions ) > 0 ) {
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
	testCondition2 = function() {
		return false;
	}
	
    animation = new cAnimoData();
    
    animationSequence = new cAnimoSequence()
    .AddAnim( animation, [testCondition] )
    .AddLoop( animation, 4, [testCondition] )
    .AddAnim( animation, [testCondition] );
    
    return animationSequence;
}