local engine = require('engine')
local virus_a = require('archetypes.virus_a')
local virus_b = require('archetypes.virus_b')
local virus_c = require('archetypes.virus_c')
local spawner = require('actors.spawner')

local spawners = {}

function spawners.none()
    -- do nothing
end

function spawners.a(value, difficulty, ratio)
    local rate = 1/1024 * (ratio or 1)

    local spawnloc = spawner(rate * difficulty, {TILE_CAP})

    if spawnloc then
        virus_a(spawnloc)
    end
end

function spawners.b(value, difficulty, ratio)
    local rate = 1/2048 * (ratio or 1)

    local target = spawner(rate * difficulty, TILES_CORNERS)

    if target then
        local spawnloc = nil

        traverse_breadth_first(target, function (where, tile)
            if tile.type == TILE_CAP then
                spawnloc = where
                return false
            end
            return true
        end)

        if spawnloc then
            virus_b({ x = spawnloc.x, y = spawnloc.y, target = target })
        end
    end
end

function spawners.c(value, difficulty, ratio)
    local rate = 1/2048 * (ratio or 1)

    local spawnloc = spawner(rate * difficulty, {TILE_CAP}, { mindepth = 8 })

    if spawnloc then
        virus_c(spawnloc)
    end
end

function spawners.ab(value, difficulty)
    spawners.a(value, difficulty, 0.5)
    spawners.b(value, difficulty, 0.5)
end

function spawners.ac(value, difficulty)
    spawners.a(value, difficulty, 0.5)
    spawners.c(value, difficulty, 0.5)
end

function spawners.bc(value, difficulty)
    spawners.b(value, difficulty, 0.5)
    spawners.c(value, difficulty, 0.5)
end

function spawners.abc(value, difficulty)
    spawners.a(value, difficulty, 0.5)
    spawners.b(value, difficulty, 0.5)
    spawners.c(value, difficulty, 0.5)
end

local virus_spawner = {}

function virus_spawner.update(eid, dt)
    local state = engine.entities:get_component(eid, component.script).state

    if not state.current then
        -- flipflop
        state.flipflop = -state.flipflop

        -- choose virus types
        local total_weight = 0
        for _,w in pairs(state.weights) do
            if w > 0 then
                total_weight = total_weight + w
            end
        end

        local roll = math.random() * total_weight

        local choice = nil
        local acc_weight = 0
        for k,w in pairs(state.weights) do
            if w > 0 then
                acc_weight = acc_weight + w
                if acc_weight >= roll then
                    choice = k
                    break
                end
            end
        end

        -- adjust weights
        for k,w in pairs(state.weights) do
            if k ~= choice then
                if w <= 0 then
                    state.weights[k] = w + 1
                else
                    state.weights[k] = w * 1.2
                end
            end
        end

        -- increment difficulty
        local dseq = state.difficulty
        dseq[4] = dseq[2] + dseq[3]
        table.remove(dseq, 1)
        
        local difficulty = math.floor(math.sqrt(dseq[2 + state.flipflop]))

        -- pick duration
        local duration = math.random() * 10 + 10

        -- create random curve
        local curve_max = 1.2

        local curve = {}
        for i=1,11 do curve[i] = 0 end

        local function displace_midpoints(b, e, bv, ev, d)
            if e == b then
                curve[b] = bv
                return
            end

            local dv = 1.2 / math.pow(2, d)
            local low = math.max(0, math.min(bv, ev) - dv / 2)
            local high = math.min(1.2, math.max(bv, ev) + dv / 2)
            local h = high - low
            local roll = math.random() * h + low
            local mid = math.floor((b + e) / 2 + 0.5)

            displace_midpoints(b, mid - 1, bv, roll, d + 0.5)
            displace_midpoints(mid, e, roll, ev, d + 0.5)
        end

        local mp = math.random(math.floor((#curve + 1) / 4 + 1), math.ceil((#curve + 1) * 3 / 4 - 1))

        displace_midpoints(1, mp - 1, 0, curve_max, 0)
        displace_midpoints(mp, #curve - 1, curve_max, 0, 0)

        -- set current
        state.current = {
            t = 0,
            duration = duration,
            virus = choice,
            difficulty = difficulty,
            curve = curve,
        }
    else
        local trem = math.floor(state.current.duration - state.current.t)

        if state.current.virus then
            -- calculate curve value (cosine interpolation)
            local curve = state.current.curve
            local nsegs = #curve - 1
            local progress = state.current.t / state.current.duration * nsegs + 1
            local i = math.floor(progress)
            local y1 = curve[i]
            local y2 = curve[i + 1]
            local segval = progress - i
            local balance = (1 - math.cos(segval * math.pi)) / 2
            local value = y1 * (1 - balance) + y2 * balance

            -- run spawner
            spawners[state.current.virus](math.min(value, 1), state.current.difficulty)

            -- update gui
            gui_state.threats = 'THREAT LEVEL: ' .. math.floor(value * 100) .. '%' ..
                ' (' .. string.upper(state.current.virus) .. ')' ..
                ' [' .. state.current.difficulty .. ']'
        else
            gui_state.threats = 'THREAT LEVEL: 0%'
        end

        -- increment timer
        state.current.t = state.current.t + dt

        -- check if done
        if state.current.t >= state.current.duration then
            if state.current.virus then
                state.current = {
                    t = 0,
                    duration = math.random(5, 10),
                    virus = nil,
                    difficulty = 0,
                    curve = { 0 },
                }
            else
                state.current = nil
            end
        end
    end

end

return virus_spawner
