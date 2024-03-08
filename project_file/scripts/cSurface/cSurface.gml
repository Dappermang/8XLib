function cSurface() constructor {
    position = new Vector2( 0, 0 );
    width = 32;
    height = 32;
    resolution = 1;
    format = surface_rgba8unorm;
    surface = surface_create( width * resolution, height * resolution, format );
    
    static Resize = function( _width, _height ) {
        surface_resize( surface, _width, _height );
    }
    
    // SaveState = function( buf = global.checkpoint )
    // {
    // 	buffer_get_surface( buf, GetSurf(), buffer_tell( buf ) );
    // 	buffer_get_surface( buf, GetBodySurf(), buffer_tell( buf ) );
    // };
    // LoadState = function( buf = global.checkpoint )
    // {
    // 	var width = surface_get_width( GetSurf() );	
    // 	var height = surface_get_height( GetSurf() );
    	
    // 	buffer_set_surface( buf, GetSurf(), buffer_tell( buf ) );
    // 	buffer_seek( buf, buffer_seek_relative, ( width * height ) * 4 );	
    	
    // 	buffer_set_surface( buf, GetBodySurf(), buffer_tell( buf ) );
    // 	buffer_seek( buf, buffer_seek_relative, ( width * height ) * 4 );
    // };
    
    static GetSurface = function() {
        if ( !surface_exists( surface ) ) {
            surface = surface_create( width * resolution, height * resolution, format );
        }
        
        return surface;
    }
    
    static Tick = function() {
        if ( !surface_exists( surface ) ) {
            surface = surface_create( width * resolution, height * resolution, format );
        }
    }
    
    static Draw = function() {
        draw_surface_part( surface, position.x - width, position.y - height, width, height, position.x, position.y );
    }
    
    return self;
}