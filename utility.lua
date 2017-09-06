local utility = {}
local input = require("input")
local resources = require("resources")

local menuSelect = resources.sounds.menuSelect
local menuClick = resources.sounds.menuClick

utility.rect = function(xPos, yPos, width, height)
    return {xPos = xPos, yPos = yPos, width = width, height = height}
end

local Button = {}
function Button:new(xPos, yPos, text, visible, enabled, action, font)
    local o = {
        xPos = xPos,
        yPos = yPos,
        text = text,
        visible = visible,
        enabled = enabled,
        execute = function()
            resources.playSound(menuClick)
            action()
        end,
        font = font or "largeFont"
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Button:getRect()
    return utility.rect(
        self.xPos,
        self.yPos,
        resources.getLineWidth(self.text, self.font),
        resources.getLineHeight(self.font)
    )
end

function Button:focus()
    resources.playSound(menuSelect)
end

function utility.newButton(xPos, yPos, text, visible, enabled, action, font)
    return Button:new(xPos, yPos, text, visible, enabled, action, font)
end

function utility.updateButtons(buttons)
    for i = 1, table.getn(buttons) do
        local button = buttons[i]
        if input.mouseOver(button:getRect()) then
            button.active = true
            if input.getLeftClick() then
                button.execute()
            end
        else
            button.active = false
        end
    end
end

function utility.drawButtons(buttons)
    local button = {}
    local printFunction = function()
        if button.visible then
            love.graphics.print(button.text, button.xPos, button.yPos)
        end
    end

    for i = 1, table.getn(buttons) do
        button = buttons[i]
        if button.active then
            resources.drawWithColor(
                255,
                0,
                0,
                255,
                function()
                    resources.printWithFont("smallFont", printFunction)
                end
            )
        elseif not button.enabled then
            resources.drawWithColor(
                150,
                150,
                150,
                255,
                function()
                    resources.printWithFont("smallFont", printFunction)
                end
            )
        else
            resources.printWithFont("smallFont", printFunction)
        end
    end
end

return utility
