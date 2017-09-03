--[[
    Resources module.
    All graphics and sound resources should be read from the disk here.
    This module also contains functions for playing sounds and drawing graphics.
]]
local resources = {}

--[[
    Local fields and functions
]]
-- Fonts that are created once and then accessed by resources.printWithFont
local fonts = {
    smallFont = love.graphics.newFont("resources/fonts/VCR_OSD_MONO_1.001.ttf", 20),
    largeFont = love.graphics.newFont("resources/fonts/VCR_OSD_MONO_1.001.ttf", 30)
}

-- Store images in images field
local function loadImages()
    print("loading images\n")
end

-- Store sounds in sounds field
local function loadSounds()
end

-- Store music tracks in musicTracks field (open these as streams since they will be larger)
local function loadMusicTracks()
end

--[[
    Module interface.
]]
resources.sounds = {}
resources.images = {}
resources.musicTracks = {}

resources.images.starMap = love.graphics.newImage("resources/images/starMap.png")
resources.images.nodeHighlight = love.graphics.newImage("resources/images/nodeHighlight.png")
resources.images.blueNode = love.graphics.newImage("resources/images/blueNode.png")
resources.images.greenNode = love.graphics.newImage("resources/images/greenNode.png")
resources.images.redNode = love.graphics.newImage("resources/images/redNode.png")
resources.images.yellowNode = love.graphics.newImage("resources/images/yellowNode.png")
resources.images.mermaidShip = love.graphics.newImage("resources/images/mermaidShip.png")
resources.images.combatScene = love.graphics.newImage("resources/images/combatScene.png")

-- Play a type of sound (do not refer to specific file in order to support random variations and stuff)
function resources.playSound(soundType)
end

-- Play a music track (if one is playing, stop that one first)
function resources.playMusicTrack(musicTrack)
end

-- Store the current colors, draw something with specified colors and then restore the old colors
function resources.drawWithColor(r, g, b, a, drawSomething)
    local _r, _g, _b, _a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, a)
    drawSomething()
    love.graphics.setColor(_r, _g, _b, _a)
end

function resources.printWithFont(fontName, printSomething)
    local _font = love.graphics.getFont()
    love.graphics.setFont(fonts[fontName])
    printSomething()
    love.graphics.setFont(_font)
end

function resources.load()
    loadImages()
    loadSounds()
    loadMusicTracks()
end

return resources
