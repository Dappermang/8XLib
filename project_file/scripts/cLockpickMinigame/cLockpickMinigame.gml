/* 
    This class contains the data for the minigame.
    HOW LOCK PICKING WORKS ;
    Every lock has 5 pins.
    Each lock has random 'Correct' order for each pin.
    The pin order is a randomized array of values denoting in which order the pins are to be 'picked'
    Pins are randomly selected based on the game profiles internal random seed.
*/
// TODO ; Figure out a basic gui hierarchy where interactable prompts/other stuff can be pushed/popped to
// the GUI layer/controller object w/o overloading it.
function cLockpickMinigame() class {
    pinAmount = 5; /// @is {number} The amount of pins in the lock.
    pinOrder = [0, 1, 2, 3, 4]; /// @is {array[number]} The unlock order of the pins. This should match the amount of pins preferably.
    currentPin = 0; /// @is {number} The currently selected pin.
    
    pinSetTimer = 20;
    pinSetTimerDefault = pinSetTimer;
    
    succeeding = true;
    
    attemptsLeft = 3; /// @is {number} The total amount of attempts left to try picking the lock.
    attemptOrder = [];
    attemptTimeout = 15;
    attemptTimeoutDefault = attemptTimeout;
    evaluating = false;
    attemptSucceeded = false;
    
    /// @param [array[number]] Pin order
    static SetPinOrder = function( order = undefined ) {
        if ( is_undefined( order ) ) {
            pinOrder = array_shuffle( pinOrder );
        }
        else {
            pinOrder = order;
        }
        
        pinAmount = array_length( pinOrder );
    }
    /// @desc Returns true or false depending on if the current attempt order is equal to the locks pin order.
    /// @returns {bool}
    static EvaluateUnlock = function() {
        var _result = false;
        
        if ( array_equals( pinOrder, attemptOrder ) ) {
            _result = true;
        }
        else {
            --attemptsLeft;
        }
        
        return _result;
    }
    static OnSuccess = function() {
        // Success State, reset lock.
        audio_play_sound( sndUnlock, -1, false, 0.2 );
        attemptOrder = []; // empty attempts
        currentPin = 0; // Reset selected pin back to 0, try again !
        attemptSucceeded = true;
        evaluating = false;
        attemptTimeout = attemptTimeoutDefault;
        pinSetTimer = pinSetTimerDefault;
        print( $"Succeeded." );
    }
    static OnFailure = function() {
        // Fail State, reset lock.
        audio_play_sound( sndFail, -1, false, 0.2 );
        attemptOrder = []; // empty attempts
        currentPin = 0; // Reset selected pin back to 0, try again !
        attemptSucceeded = false;
        evaluating = false;
        attemptTimeout = attemptTimeoutDefault;
        pinSetTimer = pinSetTimerDefault;
        print( $"Failed." );
    }
    static Tick = function() {
        // Todo; When moving to actual project, replace all keyboard functions with inputLib stuff.
        
        var _inputDirection = ( keyboard_check_pressed( vk_right ) - keyboard_check_pressed( vk_left ) );
        var _inputConfirm = ( mouse_check_button( mb_left ) );
        
        if ( attemptsLeft <= 0 ) {
            // No more attempts left.
            return;
        }
        
        currentPin = eucMod( currentPin + sign( _inputDirection ), pinAmount );
        currentPin = ( currentPin > pinAmount || currentPin < 0 ) ? 1 : currentPin;
        
        if ( array_length( attemptOrder ) >= pinAmount ) {
            attemptTimeout = max( 0, attemptTimeout - 1 );
            evaluating = true;
        }
        
        if ( !evaluating
        && !array_contains( attemptOrder, currentPin )
        && _inputConfirm ) {
            pinSetTimer = max( 0, pinSetTimer - 1 );
            
            if ( pinSetTimer <= 0 ) {
                array_push( attemptOrder, currentPin );
                audio_play_sound( choose( sndPin1, sndPin2, sndPin3 ), -1, false, 0.2 );
                pinSetTimer = pinSetTimerDefault;
            }
        }
        else if ( !_inputConfirm ) {
            pinSetTimer = min( pinSetTimerDefault, pinSetTimer + 1 );
        }
        
        // Check if current pin selected will be/is in the correct order and play 'hint' sound
        // checking if two arrays have the same values and value orders
        
        // Check pinOrder array values.
        // Check attemptOrder array values.
        // If we have the same order of the attempt values, then keep displaying hints ?
        if ( attemptTimeout <= 0 ) {
            if ( EvaluateUnlock() ) {
                OnSuccess();
            }
            else {
                OnFailure();
            }
        }
    }
    
    // Temporary Draw.
    static DrawDebug = function() {
        var _pinSize = 8;
        var _offset = ( 6 * _pinSize ) / 2;
        
        for( var i = 0; i < pinAmount; ++i ) {
            draw_set_color( array_contains( attemptOrder, i ) ? c_lime : c_white );
            draw_circle( 128 + ( _offset * i ), 128, _pinSize, currentPin == i ? true : false );
            draw_set_color( succeeding ? c_aqua : c_white );
            draw_circle( 128 + ( _offset * currentPin ), 128, _pinSize * ( pinSetTimer / pinSetTimerDefault ), succeeding ? true : false );
            draw_set_color( c_white );
        }
        
        draw_text( 0, 0, $"Current Pin : {currentPin}\nCurrent Attempt : {attemptOrder}\nPin Order : {pinOrder}\n{attemptTimeout}\nSpring Time : {pinSetTimer}\nAttempts : {attemptsLeft}" );
        draw_set_color( attemptSucceeded ? c_green : c_red );
        draw_text( 0, 75, attemptSucceeded ? "We Did It." : "Stupid Fuck. Try Again." );
        draw_set_color( c_white );
    }
}

function cGUIMinigame() class {
    
}