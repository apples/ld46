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

    heart_targeter(position, state, function ()
        verbose('on heart, hurting')
        game_state.health = game_state.health - 10
        verbose('my purpose has been fulfilled')
        engine.entities:destroy_entity(eid)
    end)

    verbose('done.')

    verbose = function () end
end

function bubble.on_click(eid, pos, loc)
end

return bubble
