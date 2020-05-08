if USE_JAM_VERSION then return require('jam_version.gui/gameplay_gui') end

local vdom = require('vdom')
local fps_counter = require('gui.fps_counter')
local debug_display = require('gui.debug_display')
local shop = require('gui.shop')
local health_counter = require('gui.health_counter')
local mitosis_counter = require('gui.mitosis_counter')
local time_counter = require('gui.time_counter')
local lose = require('gui.lose')
local threats = require('gui.threats')

return function(props)
    local setContext = vdom.useContextProvider(function () return props end)

    setContext(props)

    return vdom.useMemo(function ()
        if not props.lose then
            return vdom.create_element('widget', { width = '100%', height = '100%' },
                vdom.create_element(shop, {}),
                vdom.create_element(threats, {}),
                vdom.create_element(health_counter, {}),
                vdom.create_element(mitosis_counter, {}),
                vdom.create_element(time_counter, {}),
                vdom.create_element(fps_counter, {}),
                vdom.create_element(debug_display, {})
            )
        else
            return vdom.create_element('widget', { width = '100%', height = '100%' },
                vdom.create_element(lose, {}),
                vdom.create_element(health_counter, {}),
                vdom.create_element(fps_counter, {}),
                vdom.create_element(debug_display, {})
            )
        end
    end, { props.lose })
end
