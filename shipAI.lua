local shipAI = {}

local function selectGun(ship)
    local specialWeapons = {}
    if ship.weapons["debuff"] then
        table.insert(specialWeapons, "debuff")
    end
    if ship.weapons["crit"] then
        table.insert(specialWeapons, "crit")
    end
    if ship.weapons["pierce"] then
        table.insert(specialWeapons, "pierce")
    end

    if table.getn(specialWeapons) == 0 then
        return "standard"
    end

    local roll = math.random(0, 1)
    if roll == 1 then
        roll = math.random(1, table.getn(specialWeapons))
        return specialWeapons[roll]
    else
        return "standard"
    end
end

local function useSpecialAmmo(chance)
    local roll = math.random(1, 100)
    if roll <= chance * 100 then
        return false
    else
        return true
    end
end

function shipAI.takeAction(ship, target)
    local gun = selectGun(ship)
    local useAmmo = false
    if ship.numAmmo > 0 then
        if ship.shipType == "pirate" then
            useAmmo = useSpecialAmmo(0.3)
        elseif ship.type == "highLevelPirate" then
            useAmmo = useSpecialAmmo(0.4)
        elseif ship.type == "keyStarPirate" then
            useAmmo = useSpecialAmmo(0.5)
        elseif ship.type == "merchantShip" then
            useAmmo = useSpecialAmmo(0.5)
        elseif ship.type == "boss" then
            useAmmo = useSpecialAmmo(0.5)
        end
    end

    ship:attack(target, gun, useAmmo)
end

return shipAI
