// Controls drawing, line advancement, etc of the prompts
function cPromptManager() class {
    prompts = [];
    currentPrompt = 0;
    currentLine = 0;
    
    targetString = "";
    typedString = "";
    typedPosition = 0;
    typeInterval = 30 / 1000;
    typeTimer = new cTimer( typeInterval, true );
    typeWaiting = true;
    
    #region Draw Info
    transform = new cTransform2D();
    alpha = 1;
    visible = true;
    #endregion
    
    static AddPrompt = function( data ) {
        print( $"Added {data}" );
        array_push( prompts, data );
        return self;
    }
    static Display = function() {
        visible = true;
    }
    
    static Hide = function() {
        visible = false;
    }
    
    static Tick = function() {
        typeTimer.Tick();
        
        if ( typeTimer.GetTime() <= 0 ) {
            typedString += string_char_at( targetString, typedPosition );
        }
                    print( typedString );
        
        // If the Typed string is the same length as the target string, pause the timer
        if ( string_length( typedString ) == string_length( targetString ) ) {
            typeTimer.Pause();
            typeWaiting = true;
        }
        else {
            typeTimer.Unpause();
            typeWaiting = false;
        }
        
        if ( mouse_check_button_pressed( mb_middle ) ) {
            AdvanceLine();
        }
    }
    
    static AdvanceLine = function() {
        if ( typeWaiting 
        && currentPrompt < array_length( prompts ) ) {
            ++currentPrompt;
            typedString = "";
            typeWaiting = false;
        }
    }
    
    static OnConfirm = function() {}
    static OnDeny = function() {}
    
    static UpdatePrompt = function() {
        // currentPrompt.lines = [];
    }
    
    static Draw = function() {
        // Drawing the prompt text
        guiCamera();
        draw_set_alpha( alpha );
        draw_text_transformed( 240, 240, typedString, 1, 1, transform.angle );
        draw_set_alpha( 1 );
    }
}