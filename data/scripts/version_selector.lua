
local vdom = require('vdom')

function version_selector(props)
    local function load_jam() print('Loading Jam version...') props.load_jam_version() end
    local function load_new() print('Loading New version...') props.load_new_version() end 

    return vdom.create_element('widget', { width='50%', height='100%', halign='right', right=0 },
        vdom.create_element('label', { color='#fff', height=20, left=-64, bottom=480, text='Select version:' }),
        vdom.create_element('label', { color='#fff', height=20, left=-70, bottom=400, text='[JAM VERSION]', on_click=load_jam }),
        vdom.create_element('label', { color='#fff', height=20, left=-172, bottom=380, text='^ Rate based on this for Ludum Dare! ^' }),
        vdom.create_element('label', { color='#fff', height=20, left=-98, bottom=300, text='[POST-JAM VERSION]', on_click=load_new })
    )
end

local vdom_root = nil

function update_gui_state(props)
    vdom.render(vdom.create_element(version_selector, props), root_widget, vdom_root)
    vdom.flush_updates()
end

print('version_selector init done')
