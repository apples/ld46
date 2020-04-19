local engine = require('engine')
local heart = require('archetypes.heart')

local function mkspr_frames(r)
    local f = component.rowcol.new
    return { f(r, 0), f(r, 1), f(r, 2) }
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
    board_version = 1,
    board = {}
}

function set_tile(x, y, t)
    local existing_tile = get_tile(x, y)

    if existing_tile then
        local ent = existing_tile.ent

        local sprite = engine.entities:get_component(ent, component.sprite)
        sprite.frames = { component.rowcol.new(0, t) }

        existing_tile.type = t
    else
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

    game_state.board_version = game_state.board_version + 1
end

function get_tile(x, y)
    local row = game_state.board[x]

    if row then return row[y] end

    return nil
end

function get_tile_type(x, y)
    local t = get_tile(x, y)

    if t then return t.type else return nil end
end

function get_neighbors(tile, allow_caps)
    local results = {}

    if tile.type == TILE_SW then
        results[#results + 1] = { x = -1, y = 0 }
        results[#results + 1] = { x = 0, y = -1 }
    elseif tile.type == TILE_SE then
        results[#results + 1] = { x = 1, y = 0 }
        results[#results + 1] = { x = 0, y = -1 }
    elseif tile.type == TILE_NW then
        results[#results + 1] = { x = -1, y = 0 }
        results[#results + 1] = { x = 0, y = 1 }
    elseif tile.type == TILE_NE then
        results[#results + 1] = { x = 1, y = 0 }
        results[#results + 1] = { x = 0, y = 1 }
    elseif tile.type == TILE_CROSS or allow_caps and tile.type == TILE_CAP then
        results[#results + 1] = { x = -1, y = 0 }
        results[#results + 1] = { x = 1, y = 0 }
        results[#results + 1] = { x = 0, y = -1 }
        results[#results + 1] = { x = 0, y = 1 }
    end

    return results
end

function traverse_breadth_first(cb)
    local q = {{ x = 0, y = 0}}
    local visited = {}

    local function push(x, y)
        if not visited[x] or not visited[x][y] then
            if not visited[x] then visited[x] = {} end
            q[#q + 1] = { x = x, y = y}
            visited[x][y] = true
        end
    end

    while #q > 0 do
        local cur = table.remove(q, 1)
        local x = cur.x
        local y = cur.y
        local tile = get_tile(x, y)

        if tile then
            local keep_going = cb(cur, tile)
            if not keep_going then
                break
            end

            for _,v in ipairs(get_neighbors(tile)) do
                push(x + v.x, y + v.y)
            end
        end
    end
end

function pathfind(source, dest)
    local function get_H(where)
        return math.abs(source.x - where.x) + math.abs(source.y - where.y)
    end

    local q = { { x = dest.x, y = dest.y, cost = 0, value = get_H(dest) } }
    local visited = {}

    local function mark_visited(where)
        if not visited[where.x] then visited[where.x] = {} end
        visited[where.x][where.y] = true
    end

    local function push(next, x, y)
        local tile = get_tile(x, y)
        if tile and tile.type == TILE_CAP then return end
        local cur = { next = next, x = x, y = y, cost = next.cost + 1 }
        cur.value = get_H(cur) + cur.cost

        local insert_where = #q + 1

        for i,v in ipairs(q) do
            if v.value <= cur.value then
                insert_where = i
                break
            end
        end

        table.insert(q, insert_where, cur)
    end

    while #q > 0 do
        local next = table.remove(q)

        if next.x == source.x and next.y == source.y then
            return next
        end

        mark_visited(next)

        local tile = get_tile(next.x, next.y)

        for _,v in ipairs(get_neighbors(tile, true)) do
            push(next, next.x + v.x, next.y + v.y)
        end
    end
end

set_tile(0, 0, TILE_CROSS)
set_tile(-1, 0, TILE_CAP)
set_tile(1, 0, TILE_CAP)
set_tile(0, -1, TILE_CAP)
set_tile(0, 1, TILE_CAP)

gui_state = {
    fps = 0,
    debug_strings = {},
    debug_vals = {},
    game_state = game_state,
    shop_target = nil
}

heart()

print('init done')
