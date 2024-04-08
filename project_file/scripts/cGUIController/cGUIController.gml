/// @desc This function initializes the gui object!
function gui() {
    static guiPanel = new cGUI();
    return guiPanel;
}

function cGUI() constructor {
    containers = [];
    focusedElement = noone;
    hoveredElement = noone;
    focusedPanel = noone;
    hoveredPanel = noone;
    hoveredContainer = noone;
    
    mousePos = new Vector2( mouse_x, mouse_y );
    
    static Init = function(){};
    
    static Tick = function() {
        if ( mousePos.x != mouse_x 
        || mousePos.y != mouse_y ) {
            mousePos.x = mouse_x;
            mousePos.y = mouse_y;
        }
    }
    
    static DrawDebug = function() {
        var _offset = new Vector2( 0, 8 );
        
        guiCamera( __GAME_WIDTH, __GAME_HEIGHT );
        
        for( var i = 0; i < array_length( containers ); ++i ) {
            for( var j = 0; j < array_length( containers[i].children ); ++j ) {
                containers[i].children[j].DrawDebug();
            }
        }
        
        for( var i = 0; i < array_length( containers ); ++i ) {
            for( var j = 0; j < array_length( containers[i].children ); ++j ) {
                for( var k = 0; k < array_length( containers[i].children[j].children ); ++k ) {
                    draw_set_font( -1 );
                    draw_text_transformed( 0 + ( 16 * ( i + j + k ) ), 0 + ( 8 * ( i + j + k ) ), $"{containers[i].label} <- {containers[i].children[j].label} <- {containers[i].children[j].children[k].label}", 0.5, 0.5, 0 );
                }
            }
        }
        
        draw_set_font( fntConsole );
        draw_text_transformed( mousePos.x + _offset.x, mousePos.y + _offset.y, $"X:{mousePos.x}\nY:{mousePos.y}", 0.05, 0.05, 0 );
        draw_set_color( c_lime );
        draw_rectangle( mousePos.x, mousePos.y, mousePos.x + 1, mousePos.y + 1, false );
        draw_reset();
    }
    
    static AddContainer = function( _name = "newContainer" ) {
        var _container = new cGUIContainer();
        _container.label = _name;
        
        array_push( containers, _container );
        return _container;
    }
    
    static GetContainerByName = function( _name ) {
        var _name_string = string_lower( _name );
        var _result = false;
        
        for( var i = 0; i < array_length( containers ); ++i ) {
            var _target_name = string_lower( containers[i].label );
            
            // We only retrieve one instance ( because why would you be naming multiple containers the same thing ... )
            if ( _target_name == _name_string ) {
                _result = containers[i];
                break;
            }
        }
        
        return _result;
    }
}

/* 
    Basic GUI Idea ( Somewhat HTML adjacent )
    
    gui() <--- GUI Root is initialized. Similar to the 'document' in html.
    
    gui().AddContainer('Body'); <--- Adds a new container with the label 'body'
    
    The basic idea is that the GUI will have different 'containers' inside of it.
    Each container and by extension the elements are made accessible via respective Get() functions.
    
    the root gui instance is what will track mouse movement, what is hovered, etc.
    
    Accessor functions can be chained like this since they return what they find.▼▼▼▼▼
    
    gui().GetContainerByName();
    gui().GetContainerByName().GetPanelByName().GetElementByName();
    
    This would retrieve an array of elements within a named group. Useful cases would be a settings panel.
    Although you could also potentially just use a value to represent the current settings page, and change what elements are visible/active depending on that value
    
    gui().GetContainerByName().GetPanelByName().GetElementsByGroup();
    
    
    # This is the basic idea of the hierarchy.
    gui <- container <- panel <- element
    
    gui and container do not have positions or properties, they are simply data structures that hold other gui elements.
    
    Panels and Elements however, do have properties, positions and even functions.
    Element positions are always relative to their parent panel coordinates.
    
    !!! Everything is drawn in the draw-end event !!!
    
    -DRAW EVENT ORDER-
        pre-draw    <- App surface configuration
        draw-begin  <- Draw setup stuff
        draw        <- Worldspace stuff
        draw-end    <- GUI
        post-draw   <- Post processing
    ------------------
    
    This will now look like;
    gui------------------------
        container-------------------
            element(position,scale,rotation,colour)
        ----------------------------
        
        // EXAMPLE
        hud--------------------
            element_text( position, scale, rotation, number_to_track, colour )
        -----------------------
        
        Panels can also be embedded within another panel, so you could have pop-ups
        popupbutton-------------
            popup_button -> popup_panel.enable()
            popup_panel---------
                element_text( position, scale, rotation, number_to_track, colour )
            --------------------
        ------------------------
    ----------------------------
*/

function cGUIContainer() constructor {
    label = "";
    children = [];
    
    static AddPanel = function( _name = "newPanel" ) {
        var _panel = new cGUIPanel();
        _panel.label = _name;
        _panel.parent = self;
        _panel.isChild = true;
        
        array_push( children, _panel );
        return _panel;
    }
    
    static GetPanelByName = function( _name ) {
        var _name_string = string_lower( _name );
        var _result = false;
        
        for( var i = 0; i < array_length( children ); ++i ) {
            var _target_name = string_lower( children[i].label );
            
            if ( _target_name == _name_string ) {
                _result = children[i];
                break;
            }
        }
        
        return _result;
    }
}

function cGUIPanel() constructor {
    label = "";
    parent = noone;
    children = [];
    isChild = false;
    active = true;
    visible = true;
    
    debugData = {
        draw : true,
        colour : make_color_rgb( 255, 0, 0 ),
        outline : true
    };
    
    transform = new cTransform2D();
    width = 0;
    height = 0;
    
    static SetBounds = function( _width = width, _height = height ) {
        width = _width;
        height = _height;
        
        return self;
    }
    
    static OnHover = function() {}
    
    static MouseOnPanel = function() {
        var _mouseCollisionCheck = point_in_rectangle( 
            device_mouse_x_to_gui(0), 
            device_mouse_y_to_gui(0), 
            transform.position.x, 
            transform.position.y, 
            transform.position.x + width,
            transform.position.y + height,
        );
        
        if ( _mouseCollisionCheck ) {
            OnHover();
        }
        
        return _mouseCollisionCheck;
    }
    
    static GetPanelByName = function( _name ) {
        var _name_string = string_lower( _name );
        var _result = false;
        
        for( var i = 0; i < array_length( children ); ++i ) {
            var _target_name = string_lower( children[i].label );
            
            if ( _target_name == _name_string ) {
                _result = children[i];
                break;
            }
        }
        
        return _result;
    }
    
    static AddPanel = function( _name = "embeddedPanel" ) {
        var _panel = new cGUIPanel();
        _panel.label = _name;
        _panel.parent = self;
        
        array_push( children, _panel );
        return _panel;
    }
    
    static AddElement = function( _name = "newElement", _type = new cGUIElement(), _position = new Vector2( transform.position.x + 0, transform.position.y + 0 ) ) {
        var _element = _type;
        _element.label = _name;
        _element.parent = self;
        _element.transform.position = _position;
        
        array_push( children, _element );
        return _element;
    }
    
    static DrawDebug = function() {
        var _x = transform.position.x;
        var _y = transform.position.y;
        var _x2 = _x + ( width * transform.scale.x );
        var _y2 = _y + ( height * transform.scale.x );
        
        if ( debugData.draw ) {
            if ( width > 0 
            && height > 0 ) {
                draw_set_color( debugData.colour );
                draw_rectangle( _x, _y, _x2, _y2, debugData.outline );
                draw_reset();
            }
        }
    }
}

function draw_reset() {
    draw_set_color( c_white );
    draw_set_alpha( 1 );
}

function cTransform2D() constructor {
    self.position = new Vector2( 0, 0 );
    self.scale = new Vector2( 1, 1 );
    self.angle = 0;
    
    static SetNewPos = function( x = 0, y = 0 ) {
        self.position = new Vector2( x, y );
    }
}

function cTransform3D() constructor {
    self.origin = new Vector3( 0, 0, 0 );
    self.rotation = new Vector3( 0, 0, 0 );
    self.scale = new Vector3( 1, 1, 1 );
    
    static SetNewPos = function( x = 0, y = 0, z = 0 ) {
        self.origin = new Vector3( x, y, z );
    }
}

function cGUIElement() constructor {
    label = "";// The 'name' of the element
    group = "";
    parent = noone;
    active = true;
    visible = true;
    
    valueMin = 0;
    valueMax = 0;
    value = -1;
    
    transform = new cTransform2D();
    width = 0;
    height = 0;
    
    // Converts the elements value to something else.
    static ConvertValue = function( _value ) {
        switch( typeof( _value ) ) {
            case "" :
                break;
        }
    }
    
    // Function is called every step. Used for input detection.
    static Listen = function() {
        if ( point_in_rectangle( mouse_x, mouse_y, transform.x, transform.y, transform.x + width, transform.y + height ) ) {
            //
            if ( mouse_check_button( mb_left ) ) {
                OnPress();
            }
        }
    };
    
    static OnHovered = function() {};
    static OnPress = function(){};
    static OnFocus = function() {};
    
    static Draw = function(){};
}

/// @desc Text that will be displayed
function cGUIElementText() : cGUIElement() constructor {
    value = "";
    
    static Draw = function() {
        draw_text( transform.x, transform.y, value );
    }
}

/// @desc Slider.
function cGUIElementSlider() : cGUIElement() constructor {
    // Slider moves by 1 integer by default.
    step = 1;

    valueMin = 0;
    valueMax = 100;
    value = -1;
}

/*

    Design idea:
        GUI Controller --- > stored in singleton / controller object
        
        GUI Elements are rendered by the controller and ticked by the controller.
        GUI Elements can have assigned labels and categories 


*/


// Potentially will just be a camera? ( think gmod rtCameras where you can display what a camera is viewing onto a screen )
function cGUIViewport() constructor {
    width = __GAME_WIDTH;
    height = __GAME_HEIGHT;
    aspectRatio = width / height;
    
    static SetViewportSize = function( _width = camera_get_view_width( 0 ), _height = camera_get_view_height( 0 ) ) {
        width = _width;
        height = _height;
        aspectRatio = width / height;
    }
}