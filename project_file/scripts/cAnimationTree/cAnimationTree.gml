function cAnimationTree( animPlayer ) constructor {
    animationPlayer = undefined;
    tree = {
        root : {}
    };
    
    SetRoot( new cTreeNode( "root", tree ) );
    
    static GetRoot = function() {
        return tree.root;
    }    
    static SetRoot = function( newRoot ) {
        tree.root = newRoot;
    }
    static SetAnimationPlayer = function( animationPlayerReference ) {
        animationPlayer = animationPlayerReference;
    }
    
    #region Node Functions node
    /// @param {cTreeNode}
    static AddNode = function( node, _parent = undefined ) {
        if ( !is_undefined( _parent ) ) {
            _parent.AddChild( node );
        }
        else {
            GetRoot().AddChild( node );
        }
    }
    static NodeIsChild = function() {
        
    }
    #endregion
}

function cTreeNode( _parentNode = undefined, _childNode = undefined ) constructor {
    parentNode = undefined;
    childNode = undefined;
    cost = 0;
    data = {};
    
    static AddChild = function( child ) {
        child.parentNode = self;
        self.childNode = child;
    }
}