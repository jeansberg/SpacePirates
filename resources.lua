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
    smallFont = love.graphics.newFont("resources/fonts/PressStart2P-Regular.ttf", 20),
    largeFont = love.graphics.newFont("resources/fonts/PressStart2P-Regular.ttf", 30)
}

--[[
    Module interface.
]]
resources.images = {}
resources.sounds = {}
resources.music = {}

resources.images.starMap = love.graphics.newImage("resources/images/starMap.png")
resources.images.nodeHighlight = love.graphics.newImage("resources/images/nodeHighlight.png")
resources.images.blueNode = love.graphics.newImage("resources/images/blueNode.png")
resources.images.greenNode = love.graphics.newImage("resources/images/greenNode.png")
resources.images.redNode = love.graphics.newImage("resources/images/redNode.png")
resources.images.yellowNode = love.graphics.newImage("resources/images/yellowNode.png")
resources.images.mermaidShip = love.graphics.newImage("resources/images/mermaidShip.png")
resources.images.combatScene = love.graphics.newImage("resources/images/combatScene.png")

resources.sounds.lowHealth = love.audio.newSource("resources/sounds/Low Health Alarm.mp3", "static")
resources.sounds.warpDrive = love.audio.newSource("resources/sounds/Warp Drive.mp3", "static")
resources.sounds.shipDamage =
    love.audio.newSource("resources/sounds/Damage to Ship take 2.mp3", "static")
resources.sounds.laserShot = love.audio.newSource("resources/sounds/Laser Shot.mp3", "static")
resources.sounds.purchase = love.audio.newSource("resources/sounds/Purchase Sound.mp3", "static")
resources.sounds.shipDamage2 = love.audio.newSource("resources/sounds/Damage to Ship.mp3", "static")
resources.sounds.menuSelect =
    love.audio.newSource("resources/sounds/Menu Select Button.mp3", "static")
resources.sounds.shipDestroyed =
    love.audio.newSource("resources/sounds/Ship Destroyed.mp3", "static")
resources.sounds.warpDrive2 =
    love.audio.newSource("resources/sounds/Warp Drive take 2.mp3", "static")

resources.music.cityTheme = love.audio.newSource("resources/music/City.mp3", "stream")
resources.music.mainTheme = love.audio.newSource("resources/music/Main Theme.mp3", "stream")
resources.music.titleTheme = love.audio.newSource("resources/music/Title Theme.mp3", "stream")
resources.music.battleTheme = love.audio.newSource("resources/music/Battle Theme.mp3", "stream")
resources.music.bossBattle = love.audio.newSource("resources/music/Boss Battle.mp3", "stream")

-- Play a sound
function resources.playSound(sound)
    sound:rewind()
    sound:play()
end

-- Stop and rewind all music tracks
function resources.stopMusic()
    for i, v in pairs(resources.music) do
        v:stop()
        v:rewind()
    end
end

-- Play a music track
function resources.playMusic(track)
    if track:isPlaying() then
        return
    end

    resources.stopMusic()

    track:play()
end

-- Restart a music track
function resources.restartMusic(track)
    resources.stopMusic()
    track:play()
end

-- Store the current colors, draw something with specified colors and then restore the old colors
function resources.drawWithColor(r, g, b, a, drawSomething)
    local _r, _g, _b, _a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, a)
    drawSomething()
    love.graphics.setColor(_r, _g, _b, _a)
end

function resources.getLineWidth(text, fontName)
    return fonts[fontName]:getWidth(text)
end

function resources.getLineHeight(fontName)
    return fonts[fontName]:getHeight()
end

function resources.printWithFont(fontName, printSomething)
    local _font = love.graphics.getFont()
    love.graphics.setFont(fonts[fontName])
    printSomething()
    love.graphics.setFont(_font)
end

return resources
