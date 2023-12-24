function cAnimoAnimation() constructor {
    sprite = -1;
    frames = [];
    animSpeed = 0;
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
    
	// Populating the frame array with all sprite frames
	static Init = function() {
		var _imageCount = sprite_get_number( sprite );
		
		for( var i = 0; i < _imageCount; ++i ) {
			frames[i] = [i];
		}
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
	
	return self;
}

function cAnimoSequence() constructor {
    paused = false;
    currentAnimation = 0; // the index of the current animation we are on
    animations = []; // array of animations to be played within the sequence
    
    repeats = 0;
    repeatsCompleted = 0;
    
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
        currentAnimation = array_length( animations ) - 1;
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