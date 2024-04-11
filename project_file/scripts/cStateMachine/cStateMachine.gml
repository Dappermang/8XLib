function cStateMachine() class {
    #region Private
    __states = {};
    __stateStack = ds_stack_create();
    __currentState = undefined;
    __instanceRef = undefined;
    __maxStateHistory = 1; // Only one other state can stay within the stack.
    __forceExit = false;
    #endregion
    
    /// @desc Adds a new state to the state machine
    static AddState = function( state ) {
        __states[$ state.name] = state;
        return self;
    }
    /// @desc Pushes a new state to the head of the state machine
    static PushState = function( stateName ) {
        var _targetState = GetState( stateName );

        if ( is_undefined( _targetState ) ) {
            print( $"State Is Undefined" );
        }
        
        ds_stack_push( __stateStack, _targetState );
        __currentState = GetStateHead();
        __currentState.onEnter();
        return self;
    }
    static PopState = function() {
        if ( !__forceExit ) {
            __currentState.onExit();
        }
        else {
            __forceExit = false;
        }
        
        // Only pop the state if there is enough room in the stack to do so !
        if ( ds_stack_size( __stateStack ) > 1 ) {
            ds_stack_pop( __stateStack );
        }
        
        __currentState = GetStateHead();
        __currentState.onEnter();
        return self;
    }
    /// @desc Forces the onExit() to be invoked. If a state pop occurs after this, it will not invoke the onExit();
    static Exit = function() {
        __currentState.onExit();
        __forceExit = true;
        return self;
    }
    static GetStateHead = function() {
        return ds_stack_top( __stateStack );
    }
    static GetState = function( stateName ) {
        var _stateCount = struct_names_count( __states );
        var _stateName = string_lower( stateName );
        var _result = undefined;
        
        if ( struct_exists( __states, stateName ) ) {
            _result = __states[$ stateName];
        }
        
        return _result;
    }
    static ChangeState = function( stateName ) {
        var _stateCount = struct_names_count( __states );
        var _targetState = __states[$ stateName];
        
        if ( _stateCount > 0 ) {
            if ( struct_get( __states, stateName ) ) {
                __currentState.onExit();
                __currentState = _targetState;
                __currentState.onEnter();
            }
        }
        return self;
    }
    static GetActiveState = function() {
        return __currentState;
    }
    
    static Tick = function() {
        if ( !is_undefined( __currentState ) ) {
            __currentState.Tick();
        }
    }
    
    return self;
}

function cState( _name = "state" ) class {
    #region Private
    #endregion
    
    name = _name;
    stateTo = "state";
    Tick = -1;
    onEnter = -1;
    onExit = -1;
    
    static GetName = function() {
        return name;
    }
    static SetTransition = function( targetState ) {
        stateTo = targetState;
        
        return self;
    }
    static OnTick = function( func ) {
        if ( is_callable( func ) ) {
            Tick = func;
        }
        return self;
    }
    static OnEnter = function( _func = function(){} ) {
        if ( is_callable( _func ) ) {
            onEnter = _func;
        }
        return self;
    }
    static OnExit = function( _func = function(){} ) {
        if ( is_callable( _func ) ) {
            onExit = _func;
        }
        return self;
    }
}