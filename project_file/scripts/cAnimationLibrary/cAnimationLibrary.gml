function cAnimationLibrary() constructor {
    __animationList = {};
    
    static AddSection = function( setName ) {
        __animationList[$ setName] = {};
        return self;
    }
    static AddAnimation = function( animation, keyName, section ) {
        if ( is_undefined( section ) ) {
            __animationList[$ keyName] = animation;
        }
        else {
            __animationList[$ section][$ keyName] = animation;
        }
        
        return self;
    }
    
    return self;
}