// Literally just a wrapper for the debug_message function to make it more useful
function print() {
	if ( argument_count > 0 ) {
		var _console_message = "", i = 0;
		
		for( var i = 0; i < argument_count; ++i ) {
			_console_message += string( argument[i] );
			
			if ( argument_count > 1 ) {
			    _console_message += " | ";
			}
		}
		show_debug_message( _console_message );
		console().Print( _console_message );
	}
} 