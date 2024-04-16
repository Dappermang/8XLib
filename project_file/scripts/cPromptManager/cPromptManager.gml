// Controls drawing, line advancement, etc of the prompts
function cPromptManager() class {
    prompts = [];
    currentPrompt = 0;
    currentLine = 0;
    selectedOption = 0;
    
    targetString = "";
    typedString = "";
    typedPosition = 1;
    typeInterval = ( 60 / 10000 );
    typeTimer = new cTimer( typeInterval );
    typeWaiting = true;
    
    #region Draw Info
    alpha = 1;
    visible = true;
    #endregion
    
    /*
        TODO : 
        - callbacks on line end
        - timeouts with callbacks on line end + a timer
        - Prompts that can have lines jumped to just in case.
        - exmaple;;;; when callback denied -> jumpTo( denyIndex ) -> text="You have Denied the prompt..."
    
     
    */
    
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
    
    static Init = function() {
        UpdatePrompt();
    }
    static Tick = function() {
        typeTimer.Tick();
        
        // If the Typed string is the same length as the target string, pause the timer
        if ( string_length( targetString ) > 0 ) {
            if ( typeTimer.GetTime() <= 0 ) {
                typedString += string_char_at( targetString, typedPosition );
                typedPosition = max( 1, typedPosition + 1 % string_length( targetString ) );
                typeTimer.ResetTimer();
            }
            
            if ( string_length( typedString ) == string_length( targetString ) ) {
                typeTimer.Pause();
                typeWaiting = true;
            }
            else {
                typeTimer.Unpause();
                typeWaiting = false;
            }
        }
        
        var _promptHasOption = struct_get( prompts[currentPrompt].__lines[currentLine], "hasOption" );
        
        if ( _promptHasOption ) {
            if ( keyboard_check_pressed( vk_left ) ) {
                selectedOption += 1 % 1;
            }            
            if ( keyboard_check_pressed( vk_right ) ) {
                selectedOption -= 1 % 1;
            }
            
            if ( keyboard_check_pressed( vk_enter ) ) {
                if ( selectedOption == 0 ) {
                    if ( is_callable( struct_get( prompts[currentPrompt].__lines[currentLine], "callbackOnConfirm" ) ) ) {
                        struct_get( prompts[currentPrompt].__lines[currentLine], "callbackOnConfirm" )();
                    }
                }                
                if ( selectedOption == 1 ) {
                    if ( is_callable( struct_get( prompts[currentPrompt].__lines[currentLine], "callbackOnDeny" ) ) ) {
                        struct_get( prompts[currentPrompt].__lines[currentLine], "callbackOnDeny" )();
                    }
                }
                AdvanceLine();
            }
        }
        
        if ( mouse_check_button_pressed( mb_middle )
        && typeWaiting ) {
            AdvanceLine();
        }        
        if ( keyboard_check_pressed( ord( "R" ) ) ) {
            ResetTyper();
        }
    }
    
    static AdvanceLine = function() {
        // Get new line
        if ( currentPrompt < array_length( prompts ) ) {
            var promptLines = prompts[currentPrompt].GetLines();
            var promptLineCount = prompts[currentPrompt].GetLineCount();
            
            if ( currentLine < array_length( promptLines ) - 1 ) {
                currentLine = min( currentLine + 1, promptLineCount - 1 );
            } else {
                currentPrompt = min( currentPrompt + 1, array_length( prompts ) - 1 );
                currentLine = 0;
            }
            ResetTyper();
        }
        
        UpdatePrompt();
    }
    static ResetTyper = function() {
        typedPosition = 1;
        typedString = "";
        typeWaiting = false;
    }
    static UpdatePrompt = function() {
        var _index = 0;
        
        for( var i = 0; i < array_length( prompts[currentPrompt].__lines ); ++i ) {
            var _lineCanBeEntered = struct_get( prompts[currentPrompt].__lines[i], "enterCondition" )();
            
            if ( !is_undefined( _lineCanBeEntered ) ) {
                if ( _lineCanBeEntered ) {
                    _index = i;
                    break;
                }
            }
        }
        
        currentLine = _index;
        targetString = struct_get( prompts[currentPrompt].__lines[_index], "text" ) ?? "error";
    }
    
    static OnConfirm = function() {}
    static OnDeny = function() {}
    static GetPromptData = function() {
        return prompts[currentPrompt].GetLines();
    }
    
    static Draw = function() {
        // Drawing the prompt text
        guiCamera();
        draw_set_alpha( alpha );
        
        var _promptOption = struct_get( prompts[currentPrompt].__lines[currentLine], "hasOption" );
        
        if ( _promptOption 
        && typeWaiting ) {
            draw_set_colour( c_lime );
            draw_text_transformed( 240, 275, struct_get( prompts[currentPrompt].__lines[currentLine], "confirmText" ), 2, 2, 0 );
            draw_set_colour( c_red );
            draw_text_transformed( 240, 295, struct_get( prompts[currentPrompt].__lines[currentLine], "denyText" ), 2, 2, 0 );
            draw_set_colour( c_white );
        }
        
        draw_text_transformed( 240, 240, typedString, 2, 2, 0 );
        draw_set_alpha( 1 );
    }
}