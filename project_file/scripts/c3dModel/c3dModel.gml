function c3dModel() constructor {
    name = "";
    filePath = "";
    modelTexture = texMissing;
    vertexBuffer = vertex_create_buffer();
    
    transform = new cTransform3D();
    
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
    
    static SetPosition = function( x, y, z = -y ) {
        transform.origin.x = x;
        transform.origin.y = y;
        transform.origin.z = z;
        
        transformMatrix[12] = transform.origin.x;
        transformMatrix[13] = transform.origin.y;
        transformMatrix[14] = transform.origin.z;
    
        return self;
    }
    
    static SetRotation = function( pitch, yaw, roll ) {
        transform.rotation.x = pitch;
        transform.rotation.y = yaw;
        transform.rotation.z = roll;
        
        __rotationMatrix = matrix_build( 
            0, 0, 0, 
            transform.rotation.x, transform.rotation.y, transform.rotation.z, 
            1, 1, 1 
        );
        __rotationScaleMatrix = matrix_multiply( __scaleMatrix, __rotationMatrix );
        matrix_multiply( transformMatrix, __rotationScaleMatrix );

        return self;
    }
    static SetScale = function( x, y, z = y ) {
        transform.scale.x = x;
        transform.scale.y = y;
        transform.scale.z = z;
        
        __scaleMatrix = matrix_build( 
            0, 0, 0, 
            0, 0, 0, 
            transform.scale.x, transform.scale.y, transform.scale.z 
        );
        __rotationScaleMatrix = matrix_multiply( __scaleMatrix, __rotationMatrix );

        matrix_multiply( transformMatrix, __rotationScaleMatrix );
    
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
    static SetTexture = function( spriteIndex, _imageIndex = 0 ) {
        modelTexture = sprite_get_texture( spriteIndex, _imageIndex );
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
    static GetScaleMatrix = function() {
        return __scaleMatrix;
    }    
    static GetRotationMatrix = function() {
        return __rotationMatrix;
    }
    
    return self;
}