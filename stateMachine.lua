-- ##################################################################
-- # Package: State Machine
-- # This package provides state machine code that can be used by
-- # other packages
-- ##################################################################
local stateMachine = {}

-- ##################################################################
-- # Class: State
-- # Each instance of State can have enter, exit, update and draw
-- # methods. These should be implemented by the caller.
-- ##################################################################
local State = {}
function State:enter()
end
function State:exit()
end
function State:update()
end
function State:draw()
end

function State:new(enter, exit, update, draw)
    local o = {enter = enter, exit = exit, update = update, draw = draw}
    setmetatable(o, self)
    self.__index = self
    return o
end

function stateMachine.newState(enter, exit, update, draw)
    return State:new(enter, exit, update, draw)
end

-- ##################################################################
-- # Class: StateMachine
-- # A basic state machine that can switch between State objects
-- # The current state's exit() method and the new states enter()
-- # method are called on switching.
-- ##################################################################
local StateMachine = {}

function StateMachine:setState(state)
    if self.state then
        self.state:exit()
    end

    self.state = state
    self.state:enter()
end

function StateMachine:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function stateMachine.newStateMachine()
    return StateMachine:new()
end

return stateMachine