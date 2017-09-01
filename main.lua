local resources = require("resources")
local gameEngine = require("gameEngine")

function love.load()
    resources.load()
    gameEngine.init()
end

function love.update(dt)
    gameEngine.update(dt)
end

function love.draw()
    gameEngine.draw()
end