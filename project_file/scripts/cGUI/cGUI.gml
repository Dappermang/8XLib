function cGUIController() class {
    elements = [];
}
function cGUIChild() class {
    #region Private
    #endregion
    
    inputEnabled = false; /// @is {bool} If True, then input is enabled.
    drawEnabled = false; /// @is {bool} If true, then this GUI Element is drawn.
    
    /// @desc 'Closes' the element by disabling input and draw for it.
    static CloseElement = function() {
        
    }
}