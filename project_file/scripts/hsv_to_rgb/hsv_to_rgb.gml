/// @param {number} hue
/// @param {number} saturation
/// @param {number} value
/// @returns {colour}
function hsv_to_rgb( hue, saturation, value ) {
    var _h = ( hue / 100 ) * 255;
    var _s = ( hue / 100 ) * 255;
    var _v = ( hue / 100 ) * 255;
    
    return make_color_hsv( _h, _s, _v );
}