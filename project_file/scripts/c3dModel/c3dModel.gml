function c3dModel() constructor {
    name = "";
    filePath = "";
    modelTexture = sprite_get_texture( texMissing, 0 );
    vertexBuffer = vertex_create_buffer();
    
    transform = new cTransform3D();
    
    transform.scale.x = 16 * 8;
    transform.scale.y = 16 * 8;
    transform.scale.z = 16 * 8;
    
    __transformMatrix = matrix_build( 
        transform.origin.x, transform.origin.y, transform.origin.z, 
        0, 0, 0, 
        1, 1, 1 
    );
    __rotationMatrix = matrix_build( 
        0, 0, 0, 
        transform.rotation.x, transform.rotation.y, transform.rotation.z, 
        1, 1, 1 
        );
    __scaleMatrix = matrix_build( 
        0, 0, 0, 
        0, 0, 0, 
        transform.scale.x, transform.scale.y, transform.scale.z 
        );
    __rotationScaleMatrix = matrix_multiply( __rotationMatrix, __scaleMatrix );
    
    transformMatrix = matrix_multiply( __transformMatrix, __rotationScaleMatrix );
    
    static SetPosition = function( x, y, z = -y ) {
        transform.origin.x = x;
        transform.origin.y = y;
        transform.origin.z = z;
        
        __transformMatrix = matrix_build( 
            transform.origin.x, transform.origin.y, transform.origin.z, 
            0, 0, 0, 
            1, 1, 1 
        );
        __rotationMatrix = matrix_build( 
            0, 0, 0, 
            transform.rotation.x, transform.rotation.y, transform.rotation.z, 
            1, 1, 1 
            );
        __scaleMatrix = matrix_build( 
            0, 0, 0, 
            0, 0, 0, 
            transform.scale.x, transform.scale.y, transform.scale.z 
            );
        __rotationScaleMatrix = matrix_multiply( __rotationMatrix, __scaleMatrix );
        
        transformMatrix = matrix_multiply( __transformMatrix, __rotationScaleMatrix );
        return self;
    }
    static SetRotation = function( pitch, yaw, roll ) {
        transform.rotation.x = pitch;
        transform.rotation.y = yaw;
        transform.rotation.z = roll;
        
        __transformMatrix = matrix_build( 
            transform.origin.x, transform.origin.y, transform.origin.z, 
            0, 0, 0, 
            1, 1, 1 
        );
        __rotationMatrix = matrix_build( 
            0, 0, 0, 
            transform.rotation.x, transform.rotation.y, transform.rotation.z, 
            1, 1, 1 
            );
        __scaleMatrix = matrix_build( 
            0, 0, 0, 
            0, 0, 0, 
            transform.scale.x, transform.scale.y, transform.scale.z 
            );
        __rotationScaleMatrix = matrix_multiply( __scaleMatrix, __rotationMatrix );
        
        transformMatrix = matrix_multiply( __transformMatrix, __rotationScaleMatrix );
        return self;
    }
    static SetName = function( nameString ) {
        name = nameString;
        return self;
    }
    static SetModel = function( modelPath ) {
        vertexBuffer = importObjModel( modelPath + ".obj", vertexDefaultFormat() );
        
        return self;
    }
    
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
    
    return self;
}