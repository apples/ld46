local engine = require('engine')
local heart = require('archetypes.heart')

local function mkspr_frames(r)
    local f = component.rowcol.new
    return { f(r, 0), f(r, 1) }
end

config = {
}

TILE_VOID = 0
TILE_SW = 1
TILE_SE = 2
TILE_NW = 3
TILE_NE = 4
TILE_CROSS = 5
TILE_CAP = 6

SPRITE_HEART = mkspr_frames(1)
SPRITE_BLOCK = mkspr_frames(2)
SPRITE_CELL_WHITE = mkspr_frames(3)
SPRITE_CELL_BLUE = mkspr_frames(4)
SPRITE_CELL_GREEN = mkspr_frames(5)
SPRITE_VIRUS_A = mkspr_frames(6)
SPRITE_VIRUS_B = mkspr_frames(7)
SPRITE_VIRUS_C = mkspr_frames(8)

game_state = {
    board = {
        [-1] = {                  [0] = TILE_CAP                   },
        [0]  = { [-1] = TILE_CAP, [0] = TILE_CROSS, [1] = TILE_CAP },
        [1]  = {                  [0] = TILE_CAP                   },
    }
}

gui_state = {
    fps = 0,
    debug_strings = {},
    debug_vals = {},
    game_state = game_state
}

heart()

print('init done')
