local vdom = require('vdom')
local fps_counter = require('gui.fps_counter')
local debug_display = require('gui.debug_display')
local shop = require('gui.shop')
local health_counter = require('gui.health_counter')

return function(props)
    local setContext = vdom.useContextProvider(function () return props end)

    setContext(props)

    return vdom.useMemo(function ()
        return vdom.create_element('widget', { width = '100%', height = '100%' },
            vdom.create_element(shop, {}),
            vdom.create_element(health_counter, {}),
            vdom.create_element(fps_counter, {}),
            vdom.create_element(debug_display, {})
        )
    end, {})
end
