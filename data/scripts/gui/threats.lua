local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element(
        'label',
        {
            halign='left',
            valign='top',
            top=0,
            left=100,
            height = 8,
            color = '#fff',
            text = context.threats or '',
        }
    )
end
