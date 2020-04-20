local engine = require('engine')

local heart = {}

function heart.update(eid, dt)
    local script = engine.entities:get_component(eid, component.script)
    script.state.decay_timer = script.state.decay_timer + dt
    if script.state.decay_timer >= 1 then
        game_state.health = game_state.health - 1
        script.state.decay_timer = 0
    end
end

function heart.on_click(eid, pos, loc)
    gui_state.shop_target = eid
end

return heart
