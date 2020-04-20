local engine = require('engine')

local function verbose(s)
    print(s)
end

local bubble = {}

function bubble.update(eid, dt)
    verbose('bubble')

    local position = engine.entities:get_component(eid, component.position)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)

    if not state.path or state.version ~= game_state.board_version then
        verbose('needs new path')
        local path = pathfind({ x = tile_x, y = tile_y }, { x = 0, y = 0 })

        if path then
            verbose('path found (len = ' .. #path .. ')')
            state.path = path
            state.path_i = 1
            state.version = game_state.board_version
        else
            verbose('path not found')
            state.target = nil
            state.path = nil
        end
    end

    if state.path then
        verbose('has path, moving (path_i = ' .. state.path_i .. ', len = ' .. #state.path .. ')')
        local dest = state.path[state.path_i]
        local dx = dest.x - position.pos.x
        local dy = dest.y - position.pos.y
        local adx = math.abs(dx)
        local ady = math.abs(dy)

        if adx >= 1/16 then
            position.pos.x = position.pos.x + dx/adx/16
        end

        if ady >= 1/16 then
            position.pos.y = position.pos.y + dy/ady/16
        end

        if adx < 1/16 and ady < 1/16 then
            verbose('path step reached, advancing')
            local next = state.path_i + 1
            if next <= #state.path then
                state.path_i = next
            end
        end
    end

    if tile_x == 0 and tile_y == 0 then
        verbose('on heart, healing')
        game_state.health = game_state.health + 1
        verbose('my purpose has been fulfilled')
        engine.entities:destroy_entity(eid)
    else
        state.timer = 0
    end

    verbose('done.')

    verbose = function () end
end

function bubble.on_click(eid, pos, loc)
end

return bubble

