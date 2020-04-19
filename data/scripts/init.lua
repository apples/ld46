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
    board = {}
}

function make_tile(x, y, t)
    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = x
    position.pos.y = y

    local sprite = component.sprite.new()
    sprite.frames = { component.rowcol.new(0, t) }
    sprite.speed = 3
    sprite.bounce = true

    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)

    if not game_state.board[x] then
        game_state.board[x] = {}
    end

    game_state.board[x][y] = {
        type = t,
        ent = ent,
    }
end

make_tile(0, 0, TILE_CROSS)
make_tile(-1, 0, TILE_CAP)
make_tile(1, 0, TILE_CAP)
make_tile(0, -1, TILE_CAP)
make_tile(0, 1, TILE_CAP)

gui_state = {
    fps = 0,
    debug_strings = {},
    debug_vals = {},
    game_state = game_state
}

heart()

print('init done')
