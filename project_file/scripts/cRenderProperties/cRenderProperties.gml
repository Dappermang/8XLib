function cRenderProperties() class {
    width = __GAME_RES_WIDTH;
    height = __GAME_RES_HEIGHT;
    renderType = RENDER_TYPE.VIEWPORT;
    resolution = 1;
    modelScale = 32;
    position = new Vector2( 0, 0 );
    fullBright = false;
    format = surface_rgba8unorm;
    
    static SetRenderProperty = function( propertyKey, propertyValue ) {
    	var _propertyKey = string_lower( propertyKey );
    	var _propertyValueType = typeof( struct_get( GetRenderProperties(), _propertyKey ) );
    	
    	if ( struct_get( self, _propertyKey ) ) {
    		var _heldPropertyType = typeof( self[$ _propertyKey] );
    		
    		if ( _propertyValueType == _heldPropertyType ) {
    			self[$ _propertyKey] = propertyValue;
    		}
    	}
    	
    	return self;
    }
}