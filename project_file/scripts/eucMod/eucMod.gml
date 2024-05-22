/// @author https://forum.gamemaker.io/index.php?threads/how-to-wrap-a-value-without-wrap-function.104446/
/// @desc Calculates a remainder from the Euclidian division (the remainder will always be non-negative).
/// @arg {number} dividend        The dividend (i.e. the value to get the remainder of).
/// @arg {number} divisor         The divisor (i.e. the value to divide by).
/// @returns {number}
function eucMod( _dividend, _divisor ) {
    var _remainder = _dividend % _divisor;
    
    if ( _remainder >= 0 ) {
        return _remainder;
    }
    else if ( _divisor > 0 ) {
        return _remainder + _divisor;
    }
    else {
        return _remainder - _divisor;
    }
}
