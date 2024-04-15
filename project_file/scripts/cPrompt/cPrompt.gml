/* 
    Prompt Data Class.
*/
function cPrompt() class {
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
        _config[$ "text"] ??= "";
        _config[$ "confirmText"] ??= "";
        _config[$ "denyText"] ??= "";
        _config[$ "hasOption"] ??= false;
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