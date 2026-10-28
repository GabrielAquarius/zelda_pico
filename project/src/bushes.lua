-- sistema de arbustos
-- metatile 233: 2x2 tiles (233,234 / 249,250) = 16x16
-- folhas: tile 235 e tile 251 (8x8 cada)

active_bushes = {}
leaf_particles = {}

function set_bush_tiles(b, base)
    for i=0,3 do
        mset(b.tx + i%2, b.ty + flr(i/2), base > 0 and (base + i%2 + flr(i/2)*16) or 0)
    end
end

function load_bushes(bush_list)
    active_bushes = {}
    leaf_particles = {}
    if not bush_list then return end
    for b in all(bush_list) do
        add(active_bushes, {tx=b.tx, ty=b.ty, alive=true})
        set_bush_tiles(b, 233)
    end
end

function cut_bush(b)
    if not b.alive then return end
    b.alive = false
    set_bush_tiles(b, 0)

    local cx = b.tx*8 + 4
    local cy = b.ty*8 + 4
    local defs = split("-4,-4,-1.6,-1.8|4,-4,1.6,-1.8|-4,2,-1.3,-1.4|4,2,1.3,-1.4", "|")

    for i,e in ipairs(defs) do
        local d = split(e)
        add(leaf_particles, {
            x = cx + d[1],
            y = cy + d[2],
            vx = d[3],
            vy = d[4],
            timer = 0,
            life = 45,
            rot_offset = i,
        })
    end
end

-- retorna sprite e flips para simular rotacao (4 poses)
function leaf_pose(step)
    step %= 4
    return (step%2 == 0) and 235 or 251, step >= 2, step >= 2
end

function update_bushes()
    for p in all(leaf_particles) do
        p.timer += 1
        p.vy += 0.15
        p.vx *= 0.97
        p.x  += p.vx
        p.y  += p.vy

        if p.timer >= p.life then
            del(leaf_particles, p)
        end
    end
end

function check_sword_bush()
    if pstate != PSTATE.ATTACK or not equipament.sword.equipped then return end

    local hx,hy,hw,hh = get_sword_hitbox()
    if hw == 0 then return end

    for b in all(active_bushes) do
        if b.alive and rects_overlap(hx,hy,hw,hh, b.tx*8,b.ty*8,16,16) then
            cut_bush(b)
        end
    end
end

function draw_bushes()
    for p in all(leaf_particles) do
        if p.timer <= p.life - 18 or p.timer % 4 < 2 then
            local s, fx, fy = leaf_pose(flr(p.timer/4) + p.rot_offset)
            spr(s, flr(p.x), flr(p.y), 1, 1, fx, fy)
        end
    end
end
