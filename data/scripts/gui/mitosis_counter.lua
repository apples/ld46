local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element(
        'label',
        {
            halign='left',
            valign='top',
            top=0,
            left = 50,
            height = 8,
            color = '#75A1EC',
            text = 'Mitosis: ' .. context.game_state.mitosis,
        }
    )
end
