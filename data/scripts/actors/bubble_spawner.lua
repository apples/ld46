if USE_JAM_VERSION then return require('jam_version.actors/bubble_spawner') end

local engine = require('engine')
local bubble = require('archetypes.bubble')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local bubble_spawner = {}

function bubble_spawner.update(eid, dt)
    verbose('bubble_spawner')

    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    state.timer = state.timer + dt


    local pow = math.sin(state.timer) * 0.5 + 1;
    local rate = math.pow(1/512, pow)

    if not state.sfx and pow < 1 then
        play_sfx('breathe', 0.5)
        state.sfx = true
    end

    if pow > 1 then
        state.sfx = false
    end

    local spawnloc = spawner(rate, function (where, tile)
        if tile.type == TILE_NE or tile.type == TILE_SE or tile.type == TILE_NW or tile.type == TILE_SW then
            local N = get_tile_type(where.x, where.y + 1)
            local S = get_tile_type(where.x, where.y - 1)
            local E = get_tile_type(where.x + 1, where.y)
            local W = get_tile_type(where.x - 1, where.y)

            if not N or not S or not E or not W then
                return true
            end
        end
        return false
    end)

    if spawnloc then
        bubble(spawnloc)
    end

    verbose('done.')

    verbose = function () end
end

function bubble_spawner.on_click(eid, pos, loc)
end

return bubble_spawner
