/// @returns {vertex_format}
function vertexDefaultFormat() {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_normal();
    vertex_format_add_texcoord();
    vertex_format_add_colour();
    
    var _vertexFormat = vertex_format_end();
    
    return _vertexFormat;
}