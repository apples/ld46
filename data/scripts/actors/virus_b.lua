if USE_JAM_VERSION then return require('jam_version.actors/virus_b') end

local engine = require('engine')

local function verbose(s)
    print(s)
end

local function blast(x, y, sx, sy)
    local wheres = {}
    local abort = false
    verbose('begin blast at '..x..','..y..' start = '..sx..','..sy)
    traverse_breadth_first({ x = x, y = y }, function (where, tile)
        verbose('  '..where.x..','..where.y)
        if where.x == 0 and where.y == 0 then
            verbose('    at heart, aborting')
            abort = true
            return false
        end
        if where.x ~= sx or where.y ~= sy then
            verbose('    not at start, marking')
            wheres[#wheres + 1] = where
        end
        return true
    end)
    if not abort then
        verbose('  not aborted, removing')
        for _,v in ipairs(wheres) do
            verbose('    '..v.x..','..v.y)
            set_tile(v.x, v.y, TILE_VOID)
        end
        verbose('  fixing caps')
        for _,v in ipairs(wheres) do
            verbose('    '..v.x..','..v.y)

            local N = get_tile_type(v.x, v.y + 1)
            local S = get_tile_type(v.x, v.y - 1)
            local E = get_tile_type(v.x + 1, v.y)
            local W = get_tile_type(v.x - 1, v.y)

            local N_connected = (N == TILE_SE or N == TILE_SW or N == TILE_CROSS)
            local S_connected = (S == TILE_NE or S == TILE_NW or S == TILE_CROSS)
            local E_connected = (E == TILE_NW or E == TILE_SW or E == TILE_CROSS)
            local W_connected = (W == TILE_NE or W == TILE_SE or W == TILE_CROSS)

            if N_connected or S_connected or E_connected or W_connected then
                set_tile(v.x, v.y, TILE_CAP)
            end
        end
    end
    verbose('done')
end

local virus_b = {}

function virus_b.update(eid, dt)
    verbose('virus_b')

    local position = engine.entities:get_component(eid, component.position)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)

    local t = get_tile_type(tile_x, tile_y)

    if not t then
        verbose('failed')
        engine.entities:destroy_entity(eid)
        return
    end

    state.timer = state.timer + dt

    if state.timer >= 5 then
        local N = get_tile_type(tile_x, tile_y + 1)
        local S = get_tile_type(tile_x, tile_y - 1)
        local E = get_tile_type(tile_x + 1, tile_y)
        local W = get_tile_type(tile_x - 1, tile_y)

        local N_connected = N and (t == TILE_NE or t == TILE_NW or t == TILE_CROSS) and (N == TILE_SE or N == TILE_SW or N == TILE_CROSS or N == TILE_CAP)
        local S_connected = S and (t == TILE_SE or t == TILE_SW or t == TILE_CROSS) and (S == TILE_NE or S == TILE_NW or S == TILE_CROSS or S == TILE_CAP)
        local E_connected = E and (t == TILE_NE or t == TILE_SE or t == TILE_CROSS) and (E == TILE_NW or E == TILE_SW or E == TILE_CROSS or E == TILE_CAP)
        local W_connected = W and (t == TILE_NW or t == TILE_SW or t == TILE_CROSS) and (W == TILE_NE or W == TILE_SE or W == TILE_CROSS or W == TILE_CAP)

        set_tile(tile_x, tile_y, TILE_CAP)

        if N_connected then blast(tile_x, tile_y + 1, tile_x, tile_y) end
        if S_connected then blast(tile_x, tile_y - 1, tile_x, tile_y) end
        if E_connected then blast(tile_x + 1, tile_y, tile_x, tile_y) end
        if W_connected then blast(tile_x - 1, tile_y, tile_x, tile_y) end

        verbose('my purpose has been fulfilled')
        engine.entities:destroy_entity(eid)
    end

    verbose('done.')

    verbose = function () end
end

function virus_b.on_click(eid, pos, loc)
end

return virus_b
