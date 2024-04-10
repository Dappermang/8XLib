function cStateMachine() class {
    #region Private
    __states = {};
    __stateStack = ds_stack_create();
    __currentState = undefined;
    __instanceRef = undefined;
    __maxStateHistory = 1; // Only one other state can stay within the stack.
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
        __currentState.onExit();
        ds_stack_pop( __stateStack );
        __currentState = GetStateHead();
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
            if ( !is_undefined( __states[$ stateName] ) ) {
                __currentState.onEnter();
                __currentState = _targetState;
                __currentState.onExit();
            }
        }
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
    static OnEnter = function( func ) {
        if ( is_callable( func ) ) {
            onEnter = func;
        }
        return self;
    }
    static OnExit = function( func ) {
        if ( is_callable( func ) ) {
            onExit = func;
        }
        return self;
    }
}