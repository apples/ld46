if USE_JAM_VERSION then return require('jam_version.gui/fps_counter') end

local vdom = require('vdom')

local colors = { '#f0f', '#ff0', '#0ff' }

return function(props)
    local context = vdom.useContext()

    local color, setColor = vdom.useState(1)

    local size, setSize = vdom.useState(6)

    local onClick = vdom.useCallback(
        function ()
            if color == 3 then setColor(1) else setColor(color + 1) end
            setSize(size + 1)
        end,
        { color, setColor, size, setSize }
    )

    return vdom.create_element(
        'label',
        {
            halign='right',
            valign='top',
            top=0,
            height = size,
            color = colors[color],
            text = context.fps,
            on_click = onClick
        }
    )
end
