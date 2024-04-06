function modelRenderer() {
    static renderer = new c3dModelRenderer();
    return renderer;
}
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
        
        var _modelTransform = model.GetTransform().origin;
        console().Print( $"Added New Model at : {_modelTransform.x},{_modelTransform.y},{_modelTransform.z}" );
        
        return self;
    }
    static GetModel = function( modelName ) {
        var _desiredModel = undefined;
        var _desiredModelName = string_lower( modelName );
        var _modelListSized = array_length( __models );
        
        for( var i = 0; i < _modelListSized; ++i ) {
            var _currentModel = __models[i];
            var _currentModelName = string_lower( __models[i].name );
            
            if ( _currentModelName == _desiredModelName ) {
                _desiredModel = _currentModel;
                break;
            }
        }
        
        return _desiredModel;
    }
    
    static Tick = function() {
        
    }
    
    static DrawModel = function( modelName ) {
        var _modelName = string_lower( modelName );
        var _modelToDraw = GetModel( _modelName );
        
        if ( !is_undefined( _modelToDraw ) ) {
            // Begin
            matrix_set( matrix_world, _modelToDraw.GetTransformMatrix() );
            
            _modelToDraw.transform.scale.x = 10;
            _modelToDraw.transform.scale.y = 10;
            _modelToDraw.transform.scale.z = 10;            
            
            vertex_submit( _modelToDraw.GetVertexBuffer(), pr_trianglelist, _modelToDraw.GetTexture() );
            
            // End
            matrix_set( matrix_world, matrix_build_identity() );
            
        }
    }
    static DrawModels = function() {
        
    }
}