if USE_JAM_VERSION then return require('jam_version.gui/health_counter') end

local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element(
        'label',
        {
            halign='left',
            valign='top',
            top=0,
            height = 8,
            color = '#f08',
            text = 'Health: ' .. context.game_state.health .. '%',
        }
    )
end
