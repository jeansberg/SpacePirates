-- ##################################################################
-- # Package: timer.
-- # This package contains code for creating timers.
-- ##################################################################

local timer = {}

local Timer = {running = true}

function Timer:new(period)
    local o = {period = period, currentTime = period}
    setmetatable(o, self)
    self.__index = self
    print(o.currentTime)
    return o
end

function Timer:reset()
    self.running = false
    self.currentTime = 0
end

function Timer:restart()
    self.running = true
    self.currentTime = self.period
end

function Timer:update(dt)
    if not self.running then
        return false
    end

    self.currentTime = self.currentTime - dt

    if self.currentTime <= 0 then
        self:reset()
        return true
    end

    return false
end

function timer.newTimer(period)
    return Timer:new(period)
end

return timer