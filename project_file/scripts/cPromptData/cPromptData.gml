/* 
    Prompt Data Class.
*/
function cPromptData() class {
    /* 
        lines <- The dialogue for the prompt.
        
        example :
        
        promptData = new cPrompt()
        .AddLine( "This is some text." )
        .AddLine( "Read more?", true, { 
            hasOption : true 
            callbackOnConfirm : function() { AddItem( item ); } 
        } )
    */
    __lines = [];
    
    /// @param {string}
    static AddLine = function( _config = {} ) {
        /*
            enterCondition <- [function|variable|boolexpression] Function or Variable that must be true in order for this line to be called.
            text <- [string] The text for this line that will be displayed.
            hasOption <- [bool] Whether or not this line is optionable.
            
            confirmText <- [string] The text for this lines 'Confirm' option.
            denyText <- [string] The text for this lines 'Deny' option.
            
            callbackOnConfirm <- [function] Function called on 'Confirm'.
            callbackOnDeny <- [function] Function called on 'Deny'.
        */
        _config[$ "enterCondition"] ??= undefined;
        _config[$ "text"] ??= "";
        _config[$ "hasOption"] ??= false;
        _config[$ "confirmText"] ??= "";
        _config[$ "denyText"] ??= "";
        _config[$ "callbackOnConfirm"] ??= -1;
        _config[$ "callbackOnDeny"] ??= -1;
        
        print( $"Added New Line With {_config}" );
        array_push( __lines, _config );
        
        return self;
    }
    
    static GetLines = function() {
        return __lines;
    }    
    static GetLineCount = function() {
        return array_length( __lines );
    }
    
    return self;
}