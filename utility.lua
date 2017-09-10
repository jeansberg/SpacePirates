local utility = {}
local input = require("input")
local resources = require("resources")

local menuSelect = resources.sounds.menuSelect
local menuClick = resources.sounds.menuClick

utility.rect = function(xPos, yPos, width, height)
    return {xPos = xPos, yPos = yPos, width = width, height = height}
end

local Button = {}
function Button:new(xPos, yPos, text, visible, enabled, action, font, sound)
    local o = {
        xPos = xPos,
        yPos = yPos,
        text = text,
        visible = visible,
        enabled = enabled,
        execute = function()
            resources.playSound(sound or menuClick)
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

local Icon = {size = 128}
function Icon:new(xPos, yPos, image, visible, enabled, action, description, sound)
    local o = {
        xPos = xPos,
        yPos = yPos,
        image = image,
        visible = visible,
        enabled = enabled,
        execute = function()
            resources.playSound(sound or menuClick)
            action()
        end,
        font = font or "largeFont",
        description = description
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Icon:getRect()
    return utility.rect(self.xPos, self.yPos, self.size, self.size)
end

utility.UI = {}

function utility.UI.newButton(xPos, yPos, text, visible, enabled, action, font, sound)
    return Button:new(xPos, yPos, text, visible, enabled, action, font, sound)
end

function utility.UI.updateButtons(buttons)
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
        if not button.enabled then
            button.active = false
        end
    end
end

function utility.UI.drawButtons(buttons)
    local button = {}
    local printFunction = function()
        if button.visible then
            love.graphics.print(button.text, button.xPos, button.yPos)
        end
    end

    for i = 1, table.getn(buttons) do
        button = buttons[i]
        if button.selected and button.visible then
            love.graphics.rectangle(
                "line",
                button.xPos - 3,
                button.yPos - 4,
                resources.getLineWidth(button.text, "smallFont") + 1,
                resources.getLineHeight("smallFont") + 1
            )
        end

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

function utility.UI.newIcon(xPos, yPos, image, visible, enabled, action, description, sound)
    return Icon:new(xPos, yPos, image, visible, enabled, action, description, sound)
end

function utility.UI.updateIcons(icons)
    for i = 1, table.getn(icons) do
        local icon = icons[i]
        if input.mouseOver(icon:getRect()) and icon.visible then
            icon.active = true
            if input.getLeftClick() then
                if icon.enabled then
                    icon.execute()
                end
            end
        else
            icon.active = false
        end
    end
end

function utility.UI.drawIcons(icons)
    local icon = {}
    local function drawRect()
        love.graphics.rectangle("fill", icon.xPos, icon.yPos, icon.size, icon.size)
    end
    local function drawIcon()
        love.graphics.draw(icon.image, icon.xPos, icon.yPos)
    end

    for i = 1, table.getn(icons) do
        icon = icons[i]
        if icon.visible then
            if icon.active then
                resources.drawWithColor(255, 255, 255, 100, drawRect)
            end

            if icon.enabled then
                drawIcon()
            else
                resources.drawWithColor(255, 255, 255, 100, drawIcon)
            end
        end
    end
end

return utility
