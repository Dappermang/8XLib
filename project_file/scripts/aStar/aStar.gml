function heuristicCostEstimate( node, goal ) {
    return abs( node.x - goal.x ) + abs( node.y - goal.y );
}

// function aStarSearch( start, end ) {
//     var open_list = ds_priority_create();
//     var closed_list = ds_map_create();

//     var start_node = ds_map_create();
//     start_node.x = start.x;
//     start_node.y = start.y;
//     start_node.g = 0;
//     start_node.h = heuristicCostEstimate( start, end );
//     start_node.f = start_node.g + start_node.h;

//     ds_priority_add( open_list, start_node, start_node.f);
    
//     while ( !ds_priority_empty( open_list ) ) {
//         var current_node = ds_priority_delete_min(open_list);
        
//         if (current_node.x == end.x && current_node.y == end.y) {
//             // Path found, reconstruct and return it
//             var path = ds_stack_create();
//             var node = current_node;
//             while (node != undefined) {
//                 ds_stack_push(path, node);
//                 node = ds_map_find_value(closed_list, node);
//             }
//             return path;
//         }

//         // Expand current node
//         var neighbors = get_neighbors( current_node ); // Implement this function to get neighboring nodes
//         for (var i = 0; i < ds_list_size( neighbors ); ++i ) {
//             var neighbor = ds_list_find_value(neighbors, i );
//             var tentative_g = current_node.g + distance_between(current_node, neighbor); // Implement this function
//             if ( tentative_g < neighbor.g || !ds_map_exists(closed_list, neighbor)) {
//                 neighbor.g = tentative_g;
//                 neighbor.h = heuristicCostEstimate( neighbor, end );
//                 neighbor.f = neighbor.g + neighbor.h;
//                 ds_map_add(closed_list, neighbor, current_node);
//                 ds_priority_add(open_list, neighbor, neighbor.f);
//             }
//         }
//     }

//     // No path found
//     return undefined;
// }

function aStarSearchOLD( _start, _end ) {
    var cost = 0;
    var est_cost = 0;
    var f = 0;
    var open_list = [];
    var closed_list = [];
    
    array_push( open_list, _start );
    
    while( array_length( open_list ) > 0 ) {
        var lowIndex = 0;
        
        for( var i = 0; i < array_length( open_list ); ++i ) {
            if ( open_list[i].f < open_list[lowIndex].f ) {
                lowIndex = i;
            }
        }
        
        var currentNode = open_list[lowIndex];
    }
}

function astar_grid_create( cell_w, cell_h, w, h ) {
    var _grid = ds_grid_create( w, h );
    
    for( var i = 0; i < w ) {
        ds_grid_set( _grid, i, i, cell_w );
        
        for( var i = 0; i < h ) {
            ds_grid_set( _grid, i, i, cell_h );
        }
    }
    
    return _grid;
};

function aStarGraph() constructor {
    self.cellW = 0;
    self.cellH = 0;
    self.graphW = 0;
    self.graphH = 0;
    self.x = 0;
    self.y = 0;
    self.graph = [];
}