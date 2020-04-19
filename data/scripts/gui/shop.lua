local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    local close = vdom.useCallback(function ()
        print('bye')
        gui_state.shop_target = nil
    end, { context })

    if not context.shop_target then return vdom.create_element('widget', {}) end

    return vdom.create_element('widget', { width = '100%', height = '100%', on_click = close },
        vdom.create_element('widget', { width = '50%', height = '50%', halign='right', valign='top', top=0, right=0 },
            vdom.create_element('panel', { texture='shop_pane', width=16, height=16 })
        )
    )
end
