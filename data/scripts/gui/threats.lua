local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element(
        'label',
        {
            halign='left',
            valign='top',
            top=0,
            left=200,
            height = 8,
            color = '#fff',
            text = 'Virus C: ' .. context.virus_c .. '%',
        }
    )
end
