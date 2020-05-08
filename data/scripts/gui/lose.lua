if USE_JAM_VERSION then return require('jam_version.gui/lose') end

local vdom = require('vdom')

return function(props)
    local context = vdom.useContext()

    return vdom.create_element('panel', { width = '100%', height = '100%', texture = ':black' },
        vdom.create_element('label', {
            bottom = 200,
            left = 100,
            height = 12,
            color = '#fff',
            text = 'You have succumbed to the virus',
        }),
        vdom.create_element('label', {
            bottom = 160,
            left = 100,
            height = 12,
            color = '#fff',
            text = 'Score: ' .. context.score,
        }),
        vdom.create_element('label', {
            bottom = 130,
            left = 100,
            height = 12,
            color = '#fff',
            text = 'HighScore: ' .. math.floor(context.highscore),
        }),
        vdom.create_element('label', {
            bottom = 100,
            left = 200,
            height = 10,
            color = '#fff',
            text = '[Reset]',
            on_click = reset_game
        })
    )
end
