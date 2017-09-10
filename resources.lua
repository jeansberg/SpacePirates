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
local path = "resources/"
local fontPath = path .. "fonts/"
local imagePath = path .. "images/"
local soundPath = path .. "sounds/"
local musicPath = path .. "music/"

local fonts = {
    tinyFont = love.graphics.newFont(fontPath .. "PressStart2P-Regular.ttf", 10),
    smallFont = love.graphics.newFont(fontPath .. "PressStart2P-Regular.ttf", 20),
    largeFont = love.graphics.newFont(fontPath .. "PressStart2P-Regular.ttf", 30)
}

--[[
    Module interface.
]]
resources.images = {}
resources.images.starMap = love.graphics.newImage(imagePath .. "starMap.png")
resources.images.nodeHighlight = love.graphics.newImage(imagePath .. "nodeHighlight.png")
resources.images.blueNode = love.graphics.newImage(imagePath .. "blueNode.png")
resources.images.greenNode = love.graphics.newImage(imagePath .. "greenNode.png")
resources.images.redNode = love.graphics.newImage(imagePath .. "redNode.png")
resources.images.yellowNode = love.graphics.newImage(imagePath .. "yellowNode.png")
resources.images.darkNode = love.graphics.newImage(imagePath .. "darkNode.png")
resources.images.mermaidShip = love.graphics.newImage(imagePath .. "mermaidShip.png")
resources.images.combatScene = love.graphics.newImage(imagePath .. "combatScene.png")
resources.images.cityScene = love.graphics.newImage(imagePath .. "cityScene.png")
resources.images.textScene = love.graphics.newImage(imagePath .. "textScene.png")
resources.images.starrySky = love.graphics.newImage(imagePath .. "starrySky.png")
resources.images.repairIcon = love.graphics.newImage(imagePath .. "repairIcon.png")
resources.images.ammoIcon = love.graphics.newImage(imagePath .. "ammoIcon.png")
resources.images.dodgeIcon = love.graphics.newImage(imagePath .. "dodgeIcon.png")
resources.images.critIcon = love.graphics.newImage(imagePath .. "critIcon.png")
resources.images.armorIcon = love.graphics.newImage(imagePath .. "armorIcon.png")
resources.images.critCannonIcon = love.graphics.newImage(imagePath .. "critCannonIcon.png")
resources.images.debuffCannonIcon = love.graphics.newImage(imagePath .. "debuffCannonIcon.png")
resources.images.pierceCannonIcon = love.graphics.newImage(imagePath .. "pierceCannonIcon.png")
resources.images.greenLaser = love.graphics.newImage(imagePath .. "greenLaser.png")
resources.images.redLaser = love.graphics.newImage(imagePath .. "redLaser.png")
resources.images.bossPortrait = love.graphics.newImage(imagePath .. "portrait - final boss.png")
resources.images.merchantPortrait =
    love.graphics.newImage(imagePath .. "portrait - merchant ship.png")
resources.images.playerPortrait = love.graphics.newImage(imagePath .. "portrait - player.png")
resources.images.piratePortrait =
    love.graphics.newImage(imagePath .. "portrait - regular _ key pirate.png")
resources.images.bossShip = love.graphics.newImage(imagePath .. "bossShip.png")
resources.images.merchantShip = love.graphics.newImage(imagePath .. "merchantShip.png")
resources.images.pirateShip = love.graphics.newImage(imagePath .. "pirateShip.png")
resources.images.health = love.graphics.newImage(imagePath .. "health.png")

resources.sounds = {}
resources.sounds.lowHealth = love.audio.newSource(soundPath .. "Low Health Alarm.mp3", "static")
resources.sounds.warpDrive = love.audio.newSource(soundPath .. "Warp Drive.mp3", "static")
resources.sounds.damage = love.audio.newSource(soundPath .. "Damage to Ship.mp3", "static")
resources.sounds.damage2 = love.audio.newSource(soundPath .. "Damage to Ship take 2.mp3", "static")
resources.sounds.laserShot = love.audio.newSource(soundPath .. "Laser Shot.mp3", "static")
resources.sounds.purchase = love.audio.newSource(soundPath .. "Purchase Sound.mp3", "static")
resources.sounds.menuSelect = love.audio.newSource(soundPath .. "Menu Select Button.mp3", "static")
resources.sounds.shipDestroyed = love.audio.newSource(soundPath .. "Ship Destroyed.mp3", "static")
resources.sounds.warpDrive2 = love.audio.newSource(soundPath .. "Warp Drive take 2.mp3", "static")
resources.sounds.purchase = love.audio.newSource(soundPath .. "Purchase Sound.mp3", "static")
resources.sounds.menuClick = love.audio.newSource(soundPath .. "Menu Click.mp3", "static")
resources.sounds.shot = love.audio.newSource(soundPath .. "Laser Shot.mp3", "static")
resources.sounds.debuffAttack = love.audio.newSource(soundPath .. "Debuff Attack.mp3", "static")
resources.sounds.critCannon = love.audio.newSource(soundPath .. "Crit Cannon.mp3", "static")
resources.sounds.alarm = love.audio.newSource(soundPath .. "Low Health Alarm.mp3", "static")
resources.sounds.dodge = love.audio.newSource(soundPath .. "Dodge.mp3", "static")
resources.sounds.repair = love.audio.newSource(soundPath .. "Repair.mp3", "static")
resources.sounds.reload = love.audio.newSource(soundPath .. "Reload.mp3", "static")
resources.sounds.purchase = love.audio.newSource(soundPath .. "Purchase Sound.mp3", "static")

resources.music = {}
resources.music.cityTheme = love.audio.newSource(musicPath .. "City.mp3", "stream")
resources.music.mainTheme = love.audio.newSource(musicPath .. "Main Theme.mp3", "stream")
resources.music.titleTheme = love.audio.newSource(musicPath .. "Title Theme.mp3", "stream")
resources.music.battleTheme = love.audio.newSource(musicPath .. "Battle Theme.mp3", "stream")
resources.music.bossBattle = love.audio.newSource(musicPath .. "Boss Battle.mp3", "stream")
resources.music.credits = love.audio.newSource(musicPath .. "Credits.mp3", "stream")

-- Play a sound
function resources.playSound(sound)
    sound:stop()
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
    track:setLooping(true)

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

function resources.printWithFont(fontName, printSomething)
    local _font = love.graphics.getFont()
    love.graphics.setFont(fonts[fontName])
    printSomething()
    love.graphics.setFont(_font)
end

function resources.getLineWidth(text, fontName)
    return fonts[fontName]:getWidth(text)
end

function resources.getLineHeight(fontName)
    return fonts[fontName]:getHeight()
end

return resources
