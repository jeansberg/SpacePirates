local resources = require("resources")
local input = require("input")
local utility = require("utility")
local cityBackground = resources.images.cityScene
local repairIcon = resources.images.repairIcon
local ammoIcon = resources.images.ammoIcon
local dodgeIcon = resources.images.dodgeIcon
local critIcon = resources.images.critIcon
local armorIcon = resources.images.armorIcon
local critCannonIcon = resources.images.critCannonIcon
local debuffCannonIcon = resources.images.debuffCannonIcon
local pierceCannonIcon = resources.images.pierceCannonIcon

local repair = resources.sounds.repair
local reload = resources.sounds.reload

--[[
    City scene module.
    Code for handling city visits.
]]
local cityScene = {}

local iconStart = 44
local iconOffset = 150

local function showAvailable(weapons, upgrades)
    if upgrades["dodge"] then
        cityScene.icons[3].visible = true
    end
    if upgrades["crit"] then
        cityScene.icons[4].visible = true
    end
    if upgrades["armor"] then
        cityScene.icons[5].visible = true
    end

    if weapons["crit"] then
        cityScene.icons[6].visible = true
    end
    if weapons["debuff"] then
        cityScene.icons[7].visible = true
    end
    if weapons["pierce"] then
        cityScene.icons[8].visible = true
    end
end

local function updateAvailable(node)
    if not node.upgrades["dodge"] then
        cityScene.icons[3].visible = false
    end
    if not node.upgrades["crit"] then
        cityScene.icons[4].visible = false
    end
    if not node.upgrades["armor"] then
        cityScene.icons[5].visible = false
    end

    if not node.weapons["crit"] then
        cityScene.icons[6].visible = false
    end
    if not node.weapons["debuff"] then
        cityScene.icons[7].visible = false
    end
    if not node.weapons["pierce"] then
        cityScene.icons[8].visible = false
    end
end

local function updateAffordable()
    if cityScene.player.money < 50 or cityScene.player.weapons["crit"] then
        cityScene.icons[6].enabled = false
    end
    if cityScene.player.money < 50 or cityScene.player.weapons["debuff"] then
        cityScene.icons[7].enabled = false
    end
    if cityScene.player.money < 50 or cityScene.player.weapons["pierce"] then
        cityScene.icons[8].enabled = false
    end

    if cityScene.player.money < 20 or cityScene.player.dodge > 0.9 then
        cityScene.icons[3].enabled = false
    end
    if cityScene.player.money < 20 or cityScene.player.crit > 0.9 then
        cityScene.icons[4].enabled = false
    end
    if cityScene.player.money < 20 or cityScene.player.armor > 0.9 then
        cityScene.icons[5].enabled = false
    end

    if cityScene.player.money < 10 or cityScene.player.hp > 249 then
        cityScene.icons[1].enabled = false
    end

    if cityScene.player.money < 10 then
        cityScene.icons[2].enabled = false
    end
end

local function purchase(node, item)
    local player = cityScene.player
    if item == "repair" then
        player.money = player.money - 10
        player.hp = math.min(player.hp + 20, 250)
    elseif item == "ammo" then
        player.money = player.money - 10
        player.numAmmo = player.numAmmo + 1
    elseif item == "dodge" then
        player.money = player.money - 20
        player.dodge = math.min(player.dodge + 0.1, 1)
        node.upgrades["dodge"] = false
    elseif item == "crit" then
        player.money = player.money - 20
        player.crit = math.min(player.crit + 0.1, 1)
        node.upgrades["crit"] = false
    elseif item == "armor" then
        player.money = player.money - 20
        player.armor = player.armor + 1
        node.upgrades["armor"] = false
    elseif item == "debuffCannon" then
        player.money = player.money - 50
        player.weapons["debuff"] = true
        node.weapons["debuff"] = false
    elseif item == "critCannon" then
        player.money = player.money - 50
        player.weapons["crit"] = true
        node.weapons["crit"] = false
    elseif item == "pierceCannon" then
        player.money = player.money - 50
        player.weapons["pierce"] = true
        node.weapons["pierce"] = false
    end

    updateAffordable()
    updateAvailable(node)
end

function cityScene.initIcons()
    cityScene.buttons = {
        utility.UI.newButton(
            40,
            700,
            "Exit",
            true,
            true,
            function()
                cityScene.exitScene()
            end,
            "smallFont"
        )
    }

    cityScene.icons = {
        utility.UI.newIcon(
            iconStart,
            440,
            repairIcon,
            true,
            true,
            function()
                purchase(cityScene.node, "repair")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 1,
            440,
            ammoIcon,
            true,
            true,
            function()
                purchase(cityScene.node, "ammo")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 2,
            440,
            dodgeIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "dodge")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 3,
            440,
            critIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "crit")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 4,
            440,
            armorIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "armor")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 5,
            440,
            critCannonIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "critCannon")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 6,
            440,
            debuffCannonIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "debuffCannon")
            end
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 7,
            440,
            pierceCannonIcon,
            false,
            true,
            function()
                purchase(cityScene.node, "pierceCannon")
            end
        )
    }
end

function cityScene.init(exitScene)
    cityScene.exitScene = exitScene
end

--[[
    City scene class.
]]
local CityScene = {}

function CityScene:new(node, player)
    local o = {}
    cityScene.player = player
    cityScene.node = node
    cityScene.initIcons()
    updateAffordable()
    self.weapons = node.weapons
    self.upgrades = node.upgrades
    showAvailable(node.weapons, node.upgrades)
    setmetatable(o, self)
    self.__index = self
    return o
end

function CityScene:draw()
    love.graphics.draw(cityBackground, 0, 0)

    utility.UI.drawButtons(cityScene.buttons)
    utility.UI.drawIcons(cityScene.icons)
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Money:" .. cityScene.player.money, 150, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Hp:" .. cityScene.player.hp, 150, 330)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Dodge:" .. cityScene.player.dodge, 350, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Crit:" .. cityScene.player.crit, 450, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Armor:" .. cityScene.player.armor, 550, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Ammo:" .. cityScene.player.numAmmo, 350, 330)
        end
    )

    for i = 1, table.getn(self.upgrades) do
        local upgrade = self.upgrades[i]
        love.graphics.print(upgrade, 100, 100 + i * 20)
    end

    if table.getn(self.weapons) > 0 then
        love.graphics.print(self.weapons[1], 100, 200)
    end
end

function CityScene:update(dt)
    utility.UI.updateButtons(cityScene.buttons)
    utility.UI.updateIcons(cityScene.icons)
end

function cityScene.newCityScene(node, player)
    return CityScene:new(node, player)
end

return cityScene
