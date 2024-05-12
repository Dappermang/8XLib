#macro class constructor
#macro extends :
#macro MATRIX_IDENTITY __matrix_identity()
#macro DELTA delta_time / 1000000

function __matrix_identity() {
    static matrix = matrix_build_identity();
    return matrix;
}