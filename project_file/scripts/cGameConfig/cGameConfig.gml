/* 
    Game config class. 
    
    Basic structure:
    
    config {
        category {
            setting:value
        }
    }
        
    { 
        volume : { 
            master : { value : 0, valueMin : 0, valueMax : 0 }, 
            music : { value : 0, valueMin : 0, valueMax : 0 }, 
            sfx : { value : 0, valueMin : 0, valueMax : 0 } 
            }
    }
    
    Adding / Init new settings
    
    settings().AddConfig( category, label, value ) <- Auto-adds a category if none exist
    
    settings().Edit( 'vol', 'master', 5 ); <- Changes 'master' volume setting inside of 'vol' to 5.
    
    settings().SaveConfig( filename, ?path ) <- Serializes all settings data according to their values respective types and saves by default to appdata
    
*/
function settings() {
    static sClass = new cGameConfig();
    return sClass;
}

function cGameConfig() constructor {
    config = {};
    
    static AddConfig = function( category, name, value ) {
        var _category = new cConfigCategory();
        
        if ( is_undefined( config[$ category] ) ) {
            config[$ category] = _category;
        }
        
        config[$ category][$ name] = new cConfigOption();
        
        var _option_data = config[$ category][$ name];
        
        // Return the option so we can chain methods.
        return _option_data;
    }
    
    static EditOption = function( category, name, new_value, new_min, new_max ) {
        var _config = config[$ category];
        
        _config[$ name].value = new_value;
        _config[$ name].valueMin = new_min;
        _config[$ name].valueMax = new_max;
        
        return _config;
    }
    
    static EditValue = function( category, name, new_value ) {
        var _config = config[$ category];
        
        _config[$ name].value = new_value;
        _config[$ name].value = clamp( _config[$ name].value, _config[$ name].valueMin, _config[$ name].valueMax );
        
        return _config;
    }
    
    static SaveConfig = function( _filename = "config.cfg", _path = environment_get_variable( "APPDATA" ) + @"\.8xlib\" ) {
        var _configFile = {};
        var _configNames = variable_struct_get_names( config );
        
        struct_foreach( config, function( i ) {
            // _configFile = _configNames[i].Serialize();
        } );
        
        var _configData = json_stringify( config );
        var _temp_buffer = buffer_create( 0, buffer_grow, 1 );
        
        print( self.config );
        
        struct_foreach( self.config, function( i ) {
            switch( typeof( i ) ) {
                case "number":
                    buffer_write( _temp_buffer, buffer_u64, i );
                    break;
            }
        } );
        
        try {
            buffer_write( _temp_buffer, buffer_string, _configData );
            buffer_save( _temp_buffer, _filename );
            buffer_delete( _temp_buffer );
            
            show_debug_message( $"Save success! Saved: {_filename} at {_path}" );
        }
        catch(e) {
            show_debug_message( $"Failed to save: {_filename} at {_path}" );
        }
        
        return;
    }
    
    static LoadConfig = function( filename ) {
        var _config_buffer = buffer_load( filename );
        
        self.config = json_parse( buffer_read( _config_buffer, buffer_string ) );
        buffer_delete( _config_buffer );
        
        return;
    }
}

function cConfigCategory() constructor {};

function cConfigOption() constructor {
    value = 0;
    valueMin = 0;
    valueMax = 0;
    
    static Serialize = function() {
        return json_stringify( value );
    }
}