function draw_hud()
    local cx, cy = cam.x, cam.y
    camera(0, 0)

    z = {sx=1, sy=81, sw=4, sh=6}
    x = {sx=1, sy=88, sw=4, sh=6}
    bracket = {sx=6, sy=81, sw=2, sh=14}
    rupee = {sx=8, sy=81, sw=7, sh=7}
    heart = {sx=8, sy=89, sw=7, sh=7}

    rectfill(0, 108, 127, 127, 13)

    --spr(128, 0, 110, 60, 2)
    sspr(z.sx, z.sy, z.sw, z.sh, 1, 111)
    sspr(x.sx, x.sy, x.sw, x.sh, 37, 111)

    sspr(bracket.sx, bracket.sy, bracket.sw, bracket.sh, 6, 111)
    sspr(bracket.sx, bracket.sy, bracket.sw, bracket.sh, 33, 111, bracket.sw, bracket.sh, true)

    sspr(bracket.sx, bracket.sy, bracket.sw, bracket.sh, 42, 111)
    sspr(bracket.sx, bracket.sy, bracket.sw, bracket.sh, 69, 111, bracket.sw, bracket.sh, true)

    sspr(rupee.sx, rupee.sy, rupee.sw, rupee.sh, 73, 111)

    spr(162, 72, 118)
    spr(162, 80, 118)
    spr(162, 88, 118)

    local acc = 0
    for i=1, 4 do
        sspr(heart.sx, heart.sy, heart.sw, heart.sh, 96+acc, 111)
        sspr(heart.sx, heart.sy, heart.sw, heart.sh, 96+acc, 119)
        acc += 8
    end

    camera(cx, cy)
end


function current_panim_sprite()
    local total_frames=max(#panim,1)
    local frame=mid(1,panim_frame,total_frames)
    return panim[frame]
end

function get_attack_phase()
    return mid(1, flr(pattack_timer/5)+1, 3)
end

function draw_defend()
    if pstate!=PSTATE.DEFEND then return end
    if inv.shield == 0 then return end
end

-- retorna a hitbox da espada em pixels (x,y,w,h)
-- baseada na direção e fase do ataque
function get_sword_hitbox()
    if pstate != PSTATE.ATTACK then return 0,0,0,0 end
    if inv.sword == 0 then return 0,0,0,0 end

    local fase = get_attack_phase()
    local sx, sy = px, py

    if pdir == "right" then
        if fase == 1 then return sx+14, sy-8, 5, 14
        elseif fase == 2 then return sx+14, sy-8, 14, 14
        else return sx+14, sy+8, 14,  5
        end
    elseif pdir == "left" then
        if fase == 1 then return sx-8, sy-8, 5, 14
        elseif fase == 2 then return sx-14, sy-2, 14, 14
        else return sx-10, sy+8, 14,  5
        end
    elseif pdir == "up" then
        if fase == 1 then return sx+12, sy, 14, 5
        elseif fase == 2 then return sx+6, sy-8, 14, 14
        else return sx+5,  sy-12, 5, 14
        end
    elseif pdir == "down" then
        if fase == 1 then return sx+5,  sy+14, 14,  5
        elseif fase == 2 then return sx+5,  sy+14, 14, 14
        else return sx+5,  sy+14,  5, 14
        end
    end
    return 0,0,0,0
end

function draw_attack(dir)
    if inv.sword == 0 then return end

    local sx, sy = px, py
    local fase = get_attack_phase()

    if dir == "right" then
        if fase == 1 then
            sspr(
                items_size.sword.ver.sx, items_size.sword.ver.sy,
                items_size.sword.ver.sw, items_size.sword.ver.sh,
                sx+12, sy-8
            )
        elseif fase == 2 then
            sspr(
                items_size.sword.diag.sx, items_size.sword.diag.sy,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                sx+12, sy-8
            )
        else
            sspr(
                items_size.sword.hor.sx, items_size.sword.hor.sy,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                sx+12, sy+8
            )
        end

    elseif dir == "left" then
        if fase == 1 then
            sspr(
                items_size.sword.ver.sx, items_size.sword.ver.sy,
                items_size.sword.ver.sw, items_size.sword.ver.sh,
                sx-8, sy-8
            )
        elseif fase == 2 then
            sspr(
                items_size.sword.diag.sx, items_size.sword.diag.sy,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                sx-12, sy-2,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                true, false
            )
        else
            sspr(
                items_size.sword.hor.sx, items_size.sword.hor.sy,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                sx-10, sy+8,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                true, false
            )
        end

    elseif dir == "up" then
        if fase == 1 then
            sspr(
                items_size.sword.hor.sx, items_size.sword.hor.sy,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                sx+12, sy
            )
        elseif fase == 2 then
            sspr(
                items_size.sword.diag.sx, items_size.sword.diag.sy,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                sx+6, sy-8
            )
        else
            sspr(
                items_size.sword.ver.sx, items_size.sword.ver.sy,
                items_size.sword.ver.sw, items_size.sword.ver.sh,
                sx+5, sy-12
            )
        end

    elseif dir == "down" then
        if fase == 1 then
            sspr(
                items_size.sword.hor.sx, items_size.sword.hor.sy,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                sx+5, sy+14,
                items_size.sword.hor.sw, items_size.sword.hor.sh,
                true, false
            )
        elseif fase == 2 then
            sspr(
                items_size.sword.diag.sx, items_size.sword.diag.sy,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                sx+5, sy+14,
                items_size.sword.diag.sw, items_size.sword.diag.sh,
                false, true
            )
        else
            sspr(
                items_size.sword.ver.sx, items_size.sword.ver.sy,
                items_size.sword.ver.sw, items_size.sword.ver.sh,
                sx+5, sy+14,
                items_size.sword.ver.sw, items_size.sword.ver.sh,
                false, true
            )
        end
    end
end

function draw_walk_with_shield()
    if inv.shield == 0 or pstate==PSTATE.ATTACK or pstate==PSTATE.PICKUP or pstate==PSTATE.PUSH then return end

    local s = items_size.shield
    local sh_data = nil
    local offpx, offpy = 0, 0
    
    local is_moving = (psx != 0 or psy != 0)
    local step = 1
    if is_moving then
        step = (flr(timer_frame/8) % 2) + 1
    end

    if pdir == "down" then
        sh_data = s.down[step] 
        offpx, offpy = 0, 2
        if step == 2 then offpy += 1 end

    elseif pdir == "up" then
        sh_data = s.up[step]

        offpx, offpy = 12, 5
        if step == 2 then offpy += 1 end

    elseif pdir == "right" then
        sh_data = s.right
        offpx, offpy = 1, 8
        if step == 2 then offpx += 1 end
    end

    if sh_data then
        sspr(
            sh_data.sx, sh_data.sy, 
            sh_data.sw, sh_data.sh, 
            px + offpx, py + offpy
        )
    end
end

function draw_pickup_item()
    if pstate != PSTATE.PICKUP then return end
    if pickup_item_kind == nil then return end

    local d = get_item_sprdata(pickup_item_kind)
    local ix = px + 8 - flr(d.sw / 2)
    local iy = py - d.sh - 2
    sspr(d.sx, d.sy, d.sw, d.sh, ix, iy)
end

function draw_player()
    local spr_id = current_panim_sprite()
    local flip = (pstate==PSTATE.DEFEND) and false or pflipx

    if pdir == "up" then
        if pstate!=PSTATE.DEFEND then
            draw_walk_with_shield()
        end
    end

    if pstate==PSTATE.ATTACK and pdir == "up" then
        draw_attack(pdir)
    end

    spr(spr_id, px, py, 2, 2, flip)

    draw_pickup_item()

    if pdir != "up" then
        if pstate!=PSTATE.DEFEND then
            draw_walk_with_shield()
        end
    end

    if pstate==PSTATE.ATTACK and pdir != "up" then
        draw_attack(pdir)
    end

    draw_defend()
end