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
    currentPin = 0; /// @is {number} The currently selected pin.
    
    attemptOrder = [];
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
        attemptOrder = []; // empty attempts
        currentPin = 0; // Reset selected pin back to 0, try again !
        attemptSucceeded = true;
    }
    static OnFailure = function() {
        // Fail State, reset lock.
        attemptOrder = []; // empty attempts
        currentPin = 0; // Reset selected pin back to 0, try again !
        audio_play_sound( audTest, -1, false, 0.1 );
        attemptSucceeded = false;
    }
    static Tick = function() {
        // Todo; When moving to actual project, replace all keyboard functions with inputLib stuff.
        
        var _inputDirection = ( keyboard_check_pressed( vk_right ) - keyboard_check_pressed( vk_left ) );
        var _inputConfirm = ( mouse_check_button_pressed( mb_left ) );
        
        currentPin = eucMod( currentPin + sign( _inputDirection ), pinAmount + 1 );
        currentPin = ( currentPin > pinAmount || currentPin < 0 ) ? 1 : currentPin;
        
        if ( _inputConfirm ) {
            array_push( attemptOrder, currentPin );
            
            if ( array_length( attemptOrder ) >= pinAmount ) {
                if ( EvaluateUnlock() ) {
                    OnSuccess();
                }
                else {
                    OnFailure();
                }
            }
        }
    }
    
    // Temporary Draw.
    static DrawDebug = function() {
        draw_text( 0, 0, $"Current Pin : {currentPin}\nCurrent Attempt : {attemptOrder}\nPin Order : {pinOrder}" );
        draw_set_color( attemptSucceeded ? c_green : c_red );
        draw_text( 0, 75, attemptSucceeded ? "We Did It." : "Stupid Fuck. Try Again." );
    }
}

function cGUIMinigame() class {
    
}
