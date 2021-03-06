if USE_JAM_VERSION then return require('jam_version.gui/shop') end

local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element('widget', { width = '100%', height = '100%' },
        vdom.create_element('panel', {
            texture='shop_pane_blue_priced',
            width=32,
            height=32,
            left=0,
            bottom=0,
            on_click=buy_blue,
        }),
        vdom.create_element('panel', {
            texture='shop_pane_green_priced',
            width=32,
            height=32,
            left=32,
            bottom=0,
            on_click=buy_green,
        }),
        vdom.create_element('panel', {
            texture='shop_pane_white_priced',
            width=32,
            height=32,
            left=64,
            bottom=0,
            on_click=buy_white,
        })
    )
end
