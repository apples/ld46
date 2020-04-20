local engine = require('engine')

local function verbose(s)
    print(s)
end

local rps_card = {}

function rps_card.update(eid, dt)
    verbose('rps_card')

    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    state.timer = state.timer - dt

    if state.timer <= 0 then
        engine.entities:destroy_entity(eid)
    end

    verbose('done.')

    verbose = function () end
end

return rps_card
