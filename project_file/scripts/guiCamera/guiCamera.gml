/// @author Sage64, Elysia
/// @desc Creates a camera to use for drawing GUI, USE IN DRAW END.
function guiCamera( width = 1920.0, height = 1080.0 ) {
	var xx = width / 2.0;
	var yy = height / 2.0;
	var camera_new = camera_create();
	
	camera_set_view_mat( camera_new, matrix_build_lookat( xx, yy, 0, xx, yy, 0, 0, 0, 1 ) );
	camera_set_proj_mat( camera_new, matrix_build_projection_ortho( width, height, -16000, 16000 ) );
	camera_set_view_pos( camera_new, 0, 0 );
	camera_set_view_size( camera_new, width, height );
	camera_set_view_angle( camera_new, 0 );
	camera_apply( camera_new );
};