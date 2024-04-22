#macro class constructor
#macro extends :
#macro MATRIX_IDENTITY __matrix_identity()

function __matrix_identity() {
    static matrix = matrix_build_identity();
    return matrix;
}