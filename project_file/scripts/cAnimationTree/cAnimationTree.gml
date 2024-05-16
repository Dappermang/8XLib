function cAnimationTree( animPlayer ) class {
    animationPlayer = undefined;
    root = new cNode();
    
    static GetRoot = function() {
        return root;
    }    
    static SetRoot = function( newRoot ) {
        root = newRoot;
    }
    static SetAnimationPlayer = function( animationPlayerReference ) {
        animationPlayer = animationPlayerReference;
    }
    
    #region Node Functions node
    /// @param {cNode}
    static AddNode = function( node, _parent = undefined ) {
        if ( !is_undefined( _parent ) ) {
            _parent.AddChild( node );
        }
        else {
            GetRoot().AddChild( node );
        }
    }
    static GetNode = function() {
        
    }
    #endregion
}

function cNode( _data = {} ) class {
    self.data = _data;
    self.children = [];
    
    static AddChild = function( node ) {
        array_push( children, node );
        return self;
    }
}

function TestTree( _amount = 6 ) {
    var _root = new cNode();
    
    repeat( _amount ) {
        _root.AddChild( new cNode() );
    }
    
    print( _root );
}