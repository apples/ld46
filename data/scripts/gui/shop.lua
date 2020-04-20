local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element('widget', { width = '100%', height = '100%' },
        vdom.create_element('panel', {
            texture='shop_pane_blue',
            width=32,
            height=32,
            left=0,
            bottom=0,
            on_click=buy_blue,
        }),
        vdom.create_element('panel', {
            texture='shop_pane_green',
            width=32,
            height=32,
            left=32,
            bottom=0,
            on_click=buy_green,
        }),
        vdom.create_element('panel', {
            texture='shop_pane_white',
            width=32,
            height=32,
            left=64,
            bottom=0,
            on_click=buy_white,
        })
    )
end
