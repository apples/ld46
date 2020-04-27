local visitor = require('visitor')

local difficulty_manager = {}

function difficulty_manager.visit(dt)
    game_state.time = game_state.time + dt
end

return difficulty_manager
