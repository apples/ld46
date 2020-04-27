if USE_JAM_VERSION then return require('jam_version.systems/health_manager') end

local visitor = require('visitor')

local health_manager = {}

function health_manager.visit(dt)
    if game_state.health > 100 then game_state.health = 100 end
    if game_state.health < 0 then
        game_state.health = 0
        goto_lose()
    end
end

return health_manager

