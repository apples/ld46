local engine = require('engine')
local visitor = require('visitor')
local heart = require('archetypes.heart')
local bubble_spawner = require('archetypes.bubble_spawner')
local cell_blue = require('archetypes.cell_blue')
local cell_green = require('archetypes.cell_green')
local cell_white = require('archetypes.cell_white')
local virus_a_spawner = require('archetypes.virus_a_spawner')
local virus_b_spawner = require('archetypes.virus_b_spawner')
local virus_c_spawner = require('archetypes.virus_c_spawner')

local function mkspr_frames(r)
    return function (sprite)
        local f = component.rowcol.new
        sprite.frames:add(f(r, 0))
        sprite.frames:add(f(r, 1))
        sprite.frames:add(f(r, 2))
    end
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
SPRITE_BUBBLE = mkspr_frames(9)

game_state = {
    board_version = 1,
    board = {},
    health = 100,
    time = 0,
}

function goto_lose()
    visitor.visit({}, function (eid)
        engine.entities:destroy_entity(eid)
    end)
    gui_state.lose = true
end

function buy_blue()
    cell_blue()
    game_state.health = game_state.health - 1
end

function buy_green()
    cell_green()
    game_state.health = game_state.health - 5
end

function buy_white()
    cell_white()
    game_state.health = game_state.health - 1
end

function set_tile(x, y, t)
    local existing_tile = get_tile(x, y)

    if t == TILE_VOID then
        if existing_tile then
            engine.entities:destroy_entity(existing_tile.ent)
            game_state.board[x][y] = nil
        else
            return
        end
    elseif existing_tile then
        local ent = existing_tile.ent

        local sprite = engine.entities:get_component(ent, component.sprite)
        sprite.frames:clear()
        sprite.frames:add(component.rowcol.new(0, t))

        existing_tile.type = t
    else
        local ent = engine.entities:create_entity()

        local position = component.position.new()
        position.pos.x = x
        position.pos.y = y

        local sprite = component.sprite.new()
        sprite.frames:add(component.rowcol.new(0, t))
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
    trace_push('get_neighbors')
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

    trace_pop('get_neighbors')
    return results
end

function traverse_breadth_first(start, cb)
    trace_push('traverse_breadth_first')
    local q = {{ x = start.x, y = start.y, depth = 0 }}
    local visited = {}

    local function push(x, y, depth)
        if not visited[x] or not visited[x][y] then
            if not visited[x] then visited[x] = {} end
            q[#q + 1] = { x = x, y = y, depth = depth }
            visited[x][y] = true
        end
    end

    while #q > 0 do
        local cur = table.remove(q, 1)
        local x = cur.x
        local y = cur.y
        local depth = cur.depth
        local tile = get_tile(x, y)

        if tile then
            local keep_going = cb(cur, tile)
            if not keep_going then
                break
            end

            for _,v in ipairs(get_neighbors(tile)) do
                push(x + v.x, y + v.y, depth + 1)
            end
        end
    end
    trace_pop('traverse_breadth_first')
end

function pathfind(source, dest, pass_caps)
    trace_push('pathfind')
    local r = pathfind_fast(game_state.board, source, dest, pass_caps or false)
    trace_pop('pathfind')
    return #r > 0 and r or nil
end

function reset_game()
    game_state = {
        board_version = 1,
        board = {},
        health = 100,
        time = 0,
    }

    set_tile(0, 0, TILE_CROSS)
    set_tile(-1, 0, TILE_CAP)
    set_tile(1, 0, TILE_CAP)
    set_tile(0, -1, TILE_CAP)
    set_tile(0, 1, TILE_CAP)

    gui_state = {
        fps = 0,
        debug_strings = {},
        debug_vals = {},
        game_state = game_state
    }

    heart()
    bubble_spawner()
    virus_a_spawner()
    virus_b_spawner()
    virus_c_spawner()
end

reset_game()

play_bgm('beat')

print('init done')
