local gameEngine = require("gameEngine")

--[[
    This file contains the main Love2D callback functions.
]]

function love.load()
  -- For ZeroBrane Studio
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end
    --
    
    gameEngine.init()
end

function love.update(dt)
    gameEngine.update(dt)
end

function love.draw()
    gameEngine.draw()
end