/// @author DragoniteSpam https://github.com/DragoniteSpam-GameMaker-Tutorials/3DTutorial74OBJ/blob/optimized/scripts/import_obj_optimized/import_obj_optimized.gml
function importObjModel( filename, vertex_format ) {
    var buffer = buffer_load(filename);
    var content_string = buffer_read(buffer, buffer_text);
    buffer_delete(buffer);
    
    static px = buffer_create(10000, buffer_grow, 4);
    static py = buffer_create(10000, buffer_grow, 4);
    static pz = buffer_create(10000, buffer_grow, 4);
    static nx = buffer_create(10000, buffer_grow, 4);
    static ny = buffer_create(10000, buffer_grow, 4);
    static nz = buffer_create(10000, buffer_grow, 4);
    static tx = buffer_create(10000, buffer_grow, 4);
    static ty = buffer_create(10000, buffer_grow, 4);
    buffer_seek(px, buffer_seek_start, 4);
    buffer_seek(py, buffer_seek_start, 4);
    buffer_seek(pz, buffer_seek_start, 4);
    buffer_seek(nx, buffer_seek_start, 4);
    buffer_seek(ny, buffer_seek_start, 4);
    buffer_seek(nz, buffer_seek_start, 4);
    buffer_seek(tx, buffer_seek_start, 4);
    buffer_seek(ty, buffer_seek_start, 4);
    
    var lines = string_split(content_string, "\n");
    
    var vb = vertex_create_buffer();
    vertex_begin(vb, vertex_format);
    
    var i = 0;
    repeat (array_length(lines)) {
        var this_line = lines[i++];
        if (this_line == "") continue;
        
        var tokens = string_split(this_line, " ");
        
        switch (tokens[0]) {
            case "v":
                buffer_write(px, buffer_f32, real(tokens[1]));
                buffer_write(py, buffer_f32, real(tokens[3]));
                buffer_write(pz, buffer_f32, real(tokens[2]));
                break;
            case "vt":
                buffer_write(tx, buffer_f32, real(tokens[1]));
                buffer_write(ty, buffer_f32, 1 - real(tokens[2]));
                break;
            case "vn":
                buffer_write(nx, buffer_f32, real(tokens[1]));
                buffer_write(ny, buffer_f32, real(tokens[3]));
                buffer_write(nz, buffer_f32, real(tokens[2]));
                break;
            case "f":
                var n = array_length(tokens);
                for (var j = 1; j < n; j++) {
                    tokens[j] = string_split(tokens[j], "/");
                }
                for (var j = 2; j < n; j++) {
                    var v1 = tokens[1];
                    var v2 = tokens[j - 1];
                    var v3 = tokens[j];
                    
                    var pi1 = 4 * real(v1[0]);
                    var pi2 = 4 * real(v2[0]);
                    var pi3 = 4 * real(v3[0]);
                    var v1_position_x = buffer_peek(px, pi1, buffer_f32);
                    var v1_position_y = buffer_peek(py, pi1, buffer_f32);
                    var v1_position_z = buffer_peek(pz, pi1, buffer_f32);
                    var v2_position_x = buffer_peek(px, pi2, buffer_f32);
                    var v2_position_y = buffer_peek(py, pi2, buffer_f32);
                    var v2_position_z = buffer_peek(pz, pi2, buffer_f32);
                    var v3_position_x = buffer_peek(px, pi3, buffer_f32);
                    var v3_position_y = buffer_peek(py, pi3, buffer_f32);
                    var v3_position_z = buffer_peek(pz, pi3, buffer_f32);
                    
                    var v1_normal_x = 0, v1_normal_y = 0, v1_normal_z = 0;
                    var v2_normal_x = 0, v2_normal_y = 0, v2_normal_z = 0;
                    var v3_normal_x = 0, v3_normal_y = 0, v3_normal_z = 0;
                    var v1_texcoord_x = 0, v1_texcoord_y = 0;
                    var v2_texcoord_x = 0, v2_texcoord_y = 0;
                    var v3_texcoord_x = 0, v3_texcoord_y = 0;
                    
                    switch (array_length(v1)) {
                        case 2:
                            var ti = 4 * real(v1[1]);
                            v1_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                            v1_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            break;
                        case 3:
                            if (v1[1] != "") {
                                ti = 4 * real(v1[1]);
                                v1_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                                v1_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            }
                            var ni = 4 * real(v1[2]);
                            v1_normal_x = buffer_peek(nx, ni, buffer_f32);
                            v1_normal_y = buffer_peek(ny, ni, buffer_f32);
                            v1_normal_z = buffer_peek(nz, ni, buffer_f32);
                            break;
                    }
                    switch (array_length(v2)) {
                        case 2:
                            var ti = 4 * real(v2[1]);
                            v2_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                            v2_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            break;
                        case 3:
                            if (v2[1] != "") {
                                ti = 4 * real(v2[1]);
                                v2_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                                v2_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            }
                            var ni = 4 * real(v2[2]);
                            v2_normal_x = buffer_peek(nx, ni, buffer_f32);
                            v2_normal_y = buffer_peek(ny, ni, buffer_f32);
                            v2_normal_z = buffer_peek(nz, ni, buffer_f32);
                            break;
                    }
                    switch (array_length(v3)) {
                        case 2:
                            var ti = 4 * real(v3[1]);
                            v3_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                            v3_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            break;
                        case 3:
                            if (v3[1] != "") {
                                ti = 4 * real(v3[1]);
                                v3_texcoord_x = buffer_peek(tx, ti, buffer_f32);
                                v3_texcoord_y = buffer_peek(ty, ti, buffer_f32);
                            }
                            var ni = 4 * real(v3[2]);
                            v3_normal_x = buffer_peek(nx, ni, buffer_f32);
                            v3_normal_y = buffer_peek(ny, ni, buffer_f32);
                            v3_normal_z = buffer_peek(nz, ni, buffer_f32);
                            break;
                    }
                    
                    vertex_position_3d(vb, v1_position_x, v1_position_y, v1_position_z);
                    vertex_normal(vb, v1_normal_x, v1_normal_y, v1_normal_z);
                    vertex_texcoord(vb, v1_texcoord_x, v1_texcoord_y);
                    vertex_colour(vb, c_white, 1);
                    
                    vertex_position_3d(vb, v2_position_x, v2_position_y, v2_position_z);
                    vertex_normal(vb, v2_normal_x, v2_normal_y, v2_normal_z);
                    vertex_texcoord(vb, v2_texcoord_x, v2_texcoord_y);
                    vertex_colour(vb, c_white, 1);
                    
                    vertex_position_3d(vb, v3_position_x, v3_position_y, v3_position_z);
                    vertex_normal(vb, v3_normal_x, v3_normal_y, v3_normal_z);
                    vertex_texcoord(vb, v3_texcoord_x, v3_texcoord_y);
                    vertex_colour(vb, c_white, 1);
                }
                break;
        }
    }
    
    vertex_end(vb);
    vertex_freeze(vb);
    
    return vb;
}