local particles = {}

local function getBlast()
    local blast = love.graphics.newCanvas(100, 100)
    love.graphics.setCanvas(blast)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 50, 50)
    love.graphics.setCanvas()
    return blast
end

function particles.getExplosion()
    local pSystem = love.graphics.newParticleSystem(getBlast(), 30)
    pSystem:setParticleLifetime(0.5, 0.6)
    --pSystem:setLinearAcceleration(-300, -300, 300, 300)
    pSystem:setSpeed(200, 300)
    pSystem:setRadialAcceleration(40, 60)
    pSystem:setSpread(6.28)
    --pSystem:setSpin(1, 5)
    pSystem:setColors(218, 166, 112, 255, 218, 166, 112, 255, 218, 166, 112, 255, 218, 166, 112, 0)
    pSystem:setSizeVariation(1)
    pSystem:setSizes(0.7, 0)
    return pSystem
end

function particles.getBigExplosion()
    local pSystem = love.graphics.newParticleSystem(getBlast(), 30)
    pSystem:setParticleLifetime(0.3, 0.3)
    --pSystem:setLinearAcceleration(-300, -300, 300, 300)
    pSystem:setSpeed(200, 300)
    pSystem:setRadialAcceleration(40, 60)
    pSystem:setSpread(6.28)
    --pSystem:setSpin(1, 5)
    pSystem:setColors(218, 166, 112, 255, 218, 166, 112, 255, 218, 166, 112, 255, 218, 166, 112, 0)
    pSystem:setSizeVariation(1)
    pSystem:setSizes(1.5, 0)
    return pSystem
end

function particles.updateExplosions(dt, explosions)
    for i = table.getn(explosions), 1, -1 do
        local explosion = explosions[i]
        explosion:update(dt)
        if explosion:getCount() == 0 then
            table.remove(explosions, i)
        end
    end
end

return particles
