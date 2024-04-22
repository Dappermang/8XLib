function cCommand() constructor {
    // The prefix that is typed
    label = "command";
    shortHand = undefined;
    //
    
    // Arguments
    arguments = {};
    
    // Usage tip printed in console when used with the 'help' command
    usageTip = "If you're reading this, someone forgot something!";
    
    /* 
        Argument Syntax :
        [required_arg]
        <optional_arg>
    */
    static SetArguments = function() {
        for( var i = 0; i < argument_count; ++i ) {
            arguments[$ i ] = argument[i];
        };
        return self;
    }
    static Execute = function(){};
    
    return self;
}