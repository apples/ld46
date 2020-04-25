if USE_JAM_VERSION then return require('jam_version.systems/gravity') end

local engine = require('engine')
local visitor = require('visitor')

local G = -100

local gravity = {}

function gravity.visit(dt)
    visitor.visit(
        {component.velocity, component.body},
        function (eid, velocity, body)
            velocity.vel.y = velocity.vel.y + G * dt
        end
    )
end

return gravity
