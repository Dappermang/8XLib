function c3dModel() constructor {
    name = "";
    filePath = "";
    modelTexture = -1;
    vertexBuffer = vertex_create_buffer();
    
    transform = new cTransform3D();
    
    __transformMatrix = matrix_build( transform.origin.x, transform.origin.y, transform.origin.z, 0, 0, 0, 1, 1, 1 );
    __rotationMatrix = matrix_build( 0, 0, 0, transform.rotation.x, transform.rotation.y, transform.rotation.z, 1, 1, 1 );
    __scaleMatrix = matrix_build( 0, 0, 0, 0, 0, 0, transform.scale.x, transform.scale.y, transform.scale.z );
    __rotationScaleMatrix = matrix_multiply( __rotationMatrix, __scaleMatrix );
    
    transformMatrix = matrix_multiply( __transformMatrix, __rotationScaleMatrix );
    
    static GetTexture = function() {
        return modelTexture;
    }
    static GetVertexBuffer = function() {
        return vertexBuffer;
    }
    static GetTransform = function() {
        return transform;
    }    
    static GetTransformMatrix = function() {
        return transformMatrix;
    }
}