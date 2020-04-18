local engine = require('engine')
local guppy = require('archetypes.guppy')
local spawn_food = require('archetypes.food')

config = {
}

game_state = {
}

gui_state = {
    fps = 0,
    debug_strings = {},
    debug_vals = {},
    game_state = game_state
}

print('init done')
