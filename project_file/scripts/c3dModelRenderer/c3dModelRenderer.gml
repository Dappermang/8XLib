function c3dModelRenderer() constructor {
    #region Private
    __models = [];
    #endregion
    #region Class Properties
    drawEnabled = true;
    #endregion
    
    static AddModel = function( model ) {
        if ( !is_instanceof( model, c3dModel ) ) {
            throw $"Cannot add non 3d Model";
        }
        
        array_push( __models, model );
        return self;
    }
    static GetModel = function( modelName ) {
        var _desiredModel = undefined;
        var _modelName = string_lower( modelName );
        var _modelListSized = array_length( __models );
        
        for( var i = 0; i < _modelListSized; ++i ) {
            var _currentModel = __models[i];
            
            if ( _currentModel.name == _modelName ) {
                _desiredModel = _currentModel;
                break;
            }
        }
        
        return _desiredModel;
    }
    static DrawModel = function( modelName ) {
        var _modelName = string_lower( modelName );
        var _modelToDraw = GetModel( _modelName );
        
        if ( !is_undefined( _modelToDraw ) ) {
            // Begin
            matrix_set( matrix_view, _modelToDraw.GetTransformMatrix() );
            
            vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
            
            // End
            matrix_set( matrix_view, matrix_build_identity() );
            
        }
    }
    static DrawModels = function() {
        
    }
}