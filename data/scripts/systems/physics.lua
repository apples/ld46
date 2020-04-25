if USE_JAM_VERSION then return require('jam_version.systems/physics') end

local engine = require('engine')

local physics = {}

function physics.visit(dt)
    engine.physics_system(engine.entities, dt)
end

return physics
