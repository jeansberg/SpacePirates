local input = {}
local lastKey = {}
local lastButton = {}

function love.mousepressed(x, y, button, istouch)
    lastButton = button
end

function love.keypressed(key)
    lastKey = key
end

function input.getMouse()
    return love.mouse.getX(), love.mouse.getY()
end

function input.mouseOver(rect)
    local x, y = input.getMouse()
    if
        x > rect.xPos and x < rect.xPos + rect.width and y > rect.yPos and
            y < rect.yPos + rect.height
     then
        return true
    end

    return false
end

function input.getLeftClick()
    if lastButton == 1 then
        lastButton = nil
        return true
    end
end

function input.getMenuInput()
    local lastMenu = lastKey
    lastKey = nil
    if lastMenu == "up" or lastMenu == "down" or lastMenu == "return" then
        return lastMenu
    end
end

function input.getEsc()
    if lastKey == "escape" then
        lastKey = nil
        return true
    end
end

return input