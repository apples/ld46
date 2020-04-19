local engine = require('engine')

local heart = {}

function heart.update(eid, dt)
end

function heart.on_click(eid, pos, loc)
    gui_state.shop_target = eid
end

return heart
