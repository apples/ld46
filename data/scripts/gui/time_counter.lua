local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element(
        'label',
        {
            halign='left',
            valign='top',
            top=0,
            left = 300,
            height = 8,
            color = '#ccc',
            text = 'Time: ' .. math.floor(context.game_state.time),
        }
    )
end
