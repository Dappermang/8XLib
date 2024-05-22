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
    pinOrder = [1, 2, 3, 4, 5]; /// @is {array[number]} The unlock order of the pins. This should match the amount of pins preferably.
    currentPin = 1; /// @is {number} The currently selected pin.
    
    attemptOrder = [];
    attemptTimeout = 15;
    attemptTimeoutMax = attemptTimeout;
    evaluating = false;
    attemptSucceeded = false;
    
    /// @desc Returns true or false depending on if the current attempt order is equal to the locks pin order.
    /// @returns {bool}
    static EvaluateUnlock = function() {
        var _result = false;
        
        if ( array_equals( pinOrder, attemptOrder ) ) {
            _result = true;
        }
        
        return _result;
    }
    static OnSuccess = function() {
        // Success State, reset lock.
        audio_play_sound( sndUnlock, -1, false, 0.2 );
        attemptOrder = []; // empty attempts
        currentPin = 1; // Reset selected pin back to 0, try again !
        attemptSucceeded = true;
        evaluating = false;
        attemptTimeout = attemptTimeoutMax;
    }
    static OnFailure = function() {
        // Fail State, reset lock.
        audio_play_sound( sndFail, -1, false, 0.2 );
        attemptOrder = []; // empty attempts
        currentPin = 1; // Reset selected pin back to 0, try again !
        //audio_play_sound( audTest, -1, false, 0.1 );
        attemptSucceeded = false;
        evaluating = false;
        attemptTimeout = attemptTimeoutMax;
    }
    static Tick = function() {
        // Todo; When moving to actual project, replace all keyboard functions with inputLib stuff.
        
        var _inputDirection = ( keyboard_check_pressed( vk_right ) - keyboard_check_pressed( vk_left ) );
        var _inputConfirm = ( mouse_check_button_pressed( mb_left ) );
        
        currentPin = eucMod( currentPin + sign( _inputDirection ), pinAmount + 1 );
        currentPin = ( currentPin > pinAmount || currentPin < 0 ) ? 1 : currentPin;
        
        if ( array_length( attemptOrder ) >= pinAmount ) {
            attemptTimeout = max( 0, attemptTimeout - 1 );
            evaluating = true;
        }
        
        if ( !evaluating 
        && _inputConfirm ) {
            if ( !array_contains( attemptOrder, currentPin ) ) {
                array_push( attemptOrder, currentPin );
                audio_play_sound( choose( sndPin1, sndPin2, sndPin3 ), -1, false, 0.2 );
            }
        }
        
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
            draw_set_color( array_contains( attemptOrder, i + 1 ) ? c_lime : c_white );
            draw_circle( 128 + ( _offset * i ), 128, _pinSize, currentPin == i + 1 ? true : false );
            draw_set_color( c_white );
        }
        
        draw_text( 0, 0, $"Current Pin : {currentPin}\nCurrent Attempt : {attemptOrder}\nPin Order : {pinOrder}\n{attemptTimeout}" );
        draw_set_color( attemptSucceeded ? c_green : c_red );
        draw_text( 0, 75, attemptSucceeded ? "We Did It." : "Stupid Fuck. Try Again." );
        draw_set_color( c_white );
    }
}

function cGUIMinigame() class {
    
}
