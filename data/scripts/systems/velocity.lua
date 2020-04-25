if USE_JAM_VERSION then return require('jam_version.systems/velocity') end

local engine = require('engine')

local velocity = {}

function velocity.visit(dt)
    engine.velocity_system(engine.entities, dt)
end

return velocity
