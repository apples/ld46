local vdom = require('vdom')
local spawn_blue = require('archetypes.cell_blue')
local spawn_green = require('archetypes.cell_green')

return function(props)
    local context = vdom.useContext()

    local close = vdom.useCallback(function ()
        gui_state.shop_target = nil
    end, {})

    local buy_blue = vdom.useCallback(function ()
        spawn_blue()
        close()
    end, { close })

    local buy_green = vdom.useCallback(function ()
        spawn_green()
        close()
    end, { close })

    if not context.shop_target then return vdom.create_element('widget', {}) end

    return vdom.create_element('widget', { width = '100%', height = '100%', on_click = close },
        vdom.create_element('widget', { width = '50%', height = '50%', halign='right', valign='top', top=0, right=0 },
            vdom.create_element('panel', {
                texture='shop_pane_blue',
                width=16,
                height=16,
                left=8,
                bottom=-8,
                on_click=buy_blue,
            }),
            vdom.create_element('panel', {
                texture='shop_pane_green',
                width=16,
                height=16,
                left=8-32,
                bottom=-8,
                on_click=buy_green,
            })
        )
    )
end
