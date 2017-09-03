local gameEngine = require("gameEngine")

--[[
    This file contains the main Love2D callback functions.
]]

function love.load()
    gameEngine.init()
end

function love.update(dt)
    gameEngine.update(dt)
end

function love.draw()
    gameEngine.draw()
end