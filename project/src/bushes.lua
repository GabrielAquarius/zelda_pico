-- sistema de arbustos
-- metatile 233: 2x2 tiles (233,234 / 249,250) = 16x16
-- folhas: tile 235 e tile 251 (8x8 cada)

active_bushes = {}
leaf_particles = {}

local BUSH_FLAG = 0 -- reutiliza flag 0 de colisão (já setada no sprite 233 do mapa)

function load_bushes(bush_list)
    active_bushes = {}
    leaf_particles = {}
    if not bush_list then return end
    for b in all(bush_list) do
        add(active_bushes, {
            tx=b.tx, ty=b.ty, alive=true
        })
        -- escreve o metatile 2x2 no mapa
        mset(b.tx,   b.ty,   233)
        mset(b.tx+1, b.ty,   234)
        mset(b.tx,   b.ty+1, 249)
        mset(b.tx+1, b.ty+1, 250)
    end
end

function bush_px(b) return b.tx*8 end
function bush_py(b) return b.ty*8 end

function cut_bush(b)
    if not b.alive then return end
    b.alive = false

    -- limpa do mapa
    mset(b.tx,   b.ty,   0)
    mset(b.tx+1, b.ty,   0)
    mset(b.tx,   b.ty+1, 0)
    mset(b.tx+1, b.ty+1, 0)

    local cx = b.tx*8 + 8 -- centro x do arbusto
    local cy = b.ty*8 + 8 -- centro y do arbusto

    -- 4 folhas em diagonal, parábola lateral forte
    -- vx grande, vy negativo médio -> arco bem aberto
    local defs = {
        {dx=-4, dy=-4, vx=-1.6, vy=-1.8}, -- cima-esquerda
        {dx= 4, dy=-4, vx= 1.6, vy=-1.8}, -- cima-direita
        {dx=-4, dy= 2, vx=-1.3, vy=-1.4}, -- baixo-esquerda
        {dx= 4, dy= 2, vx= 1.3, vy=-1.4}, -- baixo-direita
    }

    for i,d in ipairs(defs) do
        add(leaf_particles, {
            x = cx + d.dx - 4,
            y = cy + d.dy - 4,
            vx = d.vx,
            vy = d.vy,
            timer = 0,
            life = 45, -- frames totais
            rot_offset = i, -- defasa a rotação fake entre folhas
        })
    end
end

-- retorna sprite e flips para simular rotação (4 poses)
function leaf_pose(step)
    step = step % 4
    if step == 0 then return 235, false, false end
    if step == 1 then return 251, false, false end
    if step == 2 then return 235, true,  true  end
    return                 251, true,  true
end

function update_bushes()
    for p in all(leaf_particles) do
        p.timer += 1
        p.vy += 0.15       -- gravidade
        p.vx *= 0.97       -- leve atrito (mantém arco lateral forte)
        p.x  += p.vx
        p.y  += p.vy

        if p.timer >= p.life then
            del(leaf_particles, p)
        end
    end
end

function check_sword_bush()
    if pstate != PSTATE.ATTACK then return end
    if inv.sword == 0 then return end

    local hx,hy,hw,hh = get_sword_hitbox()
    if hw == 0 or hh == 0 then return end

    for b in all(active_bushes) do
        if b.alive then
            local bx = bush_px(b)
            local by = bush_py(b)
            if rects_overlap(hx,hy,hw,hh, bx,by,16,16) then
                cut_bush(b)
            end
        end
    end
end

function draw_bushes()
    for p in all(leaf_particles) do
        -- pisca nos últimos 18 frames
        local visible = true
        if p.timer > p.life - 18 then
            visible = (p.timer % 4 < 2)
        end
        if visible then
            -- rotação fake: troca pose a cada 4 frames
            local step = flr(p.timer/4) + p.rot_offset
            local s, fx, fy = leaf_pose(step)
            spr(s, flr(p.x), flr(p.y), 1, 1, fx, fy)
        end
    end
end