if USE_JAM_VERSION then return require('jam_version.actors/virus_a') end

local engine = require('engine')
local heart_targeter = require('actors.heart_targeter')

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
    if not get_tile_type(tile_x, tile_y) then
        engine.entities:destroy_entity(eid)
        return
    end

    heart_targeter(position, state, function ()
        verbose('on heart, hurting')
        game_state.health = game_state.health - 1
        play_sfx('hit', 1)
        verbose('my purpose has been fulfilled')
        engine.entities:destroy_entity(eid)
    end)

    verbose('done.')

    verbose = function () end
end

function bubble.on_click(eid, pos, loc)
end

return bubble
