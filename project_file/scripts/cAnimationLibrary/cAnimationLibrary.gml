/// @desc A Data Structure that contains Animation Keys and their respective data. Useful for compiling and organizing animations to exist within a single Entity/Instance.
function cAnimationLibrary() constructor {
    __animationList = {};
    
    static AddSection = function( setName ) {
        __animationList[$ setName] = {};
        return self;
    }
    static AddAnimation = function( animationData, animationKey, sectionKey ) {
        if ( SectionExists( sectionKey ) ) {
            __animationList[$ sectionKey][$ animationKey] = animationData;
        }
        else {
            __animationList[$ animationKey] = animationData;
        }
        
        return self;
    }
    static SectionExists = function( sectionKey ) {
        var _result = true;
        
        if ( !struct_exists( __animationList, sectionKey ) ) {
            _result = false;
        }
        
        return _result;
    }    
    static AnimationExists = function( animationKey, sectionKey = undefined ) {
        var _result = true;
        
        if ( SectionExists( sectionKey ) ) {
            if ( !struct_exists( __animationList[$ section], animationKey ) ) {
                _result = false;
            }
        }
        else {
            if ( !struct_exists( __animationList, animationKey ) ) {
                _result = false;
            }
        }
        
        return _result;
    }
    
    #region Getters
    static GetAnimation = function( animationKey, sectionKey ) {
        var _animation = undefined;
        
        if ( SectionExists( sectionKey ) ) {
            if ( AnimationExists( animationKey, sectionKey ) ) {
                _animation = __animationList[$ section][$ animationKey];
            }
        }
        else {
            if ( AnimationExists( animationKey ) ) {
                _animation = __animationList[$ animationKey];
            }
        }
        
        return _animation;
    }
    #endregion
    
    return self;
}