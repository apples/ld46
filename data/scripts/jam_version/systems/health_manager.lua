local visitor = require('visitor')

local health_manager = {}

function health_manager.visit(dt)
    if game_state.health > 100 then game_state.health = 100 end
    if game_state.health < 0 then
        game_state.health = 0
        goto_lose()
    end
    game_state.time = game_state.time + dt
end

return health_manager

