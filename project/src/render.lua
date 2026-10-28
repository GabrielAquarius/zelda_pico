hud_items_spr = unpack_rects("shield,0,64,8,10|sword,8,64,8,16|bracelet,16,65,8,14|bow,25,65,6,14|feather,33,64,7,16|pegasus_boots,40,64,8,14|bomb,49,64,8,13|hookshot,57,64,7,16|shovel,65,64,9,14|ocarina,74,64,7,15|magic_rod,82,64,7,15|boomerang,90,64,8,12|magic_powder,98,64,8,14")

hud_digits = split("162,163,164,165,166,178,179,180,181,182")

hud_gfx = unpack_rects("bracket,6,81,2,14|heart_empty,8,89,7,7|heart_full,64,96,7,7")

sword_frames = {}
for e in all(split("ver,-8,-8,0,0,-8,-8,5,14|diag,-12,-2,1,0,-14,-2,14,14|hor,-10,8,1,0,-10,8,14,5|ver,12,-8,0,0,14,-8,5,14|diag,12,-8,0,0,14,-8,14,14|hor,12,8,0,0,14,8,14,5|hor,12,0,0,0,12,0,14,5|diag,6,-8,0,0,6,-8,14,14|ver,5,-12,0,0,5,-12,5,14|hor,5,14,1,0,5,14,14,5|diag,5,14,0,1,5,14,14,14|ver,5,14,0,1,5,14,5,14", "|")) do
    add(sword_frames, split(e))
end

function sspr_rect(d, x, y, fx, fy)
    sspr(d.sx, d.sy, d.sw, d.sh, x, y, d.sw, d.sh, fx, fy)
end

function draw_hud_slot(item_name, bx, by, bw, bh)
    local d = item_name and hud_items_spr[item_name]
    if d then
        sspr_rect(d, bx + flr((bw - d.sw) / 2), by + flr((bh - d.sh) / 2))
    end
end

function draw_hud()
    local cx, cy = cam.x, cam.y
    camera(0, 0)

    local br = hud_gfx.bracket
    local he = hud_gfx.heart_empty
    local hf = hud_gfx.heart_full

    rectfill(0, 108, 127, 127, 13)

    sspr(1, 81, 4, 6, 1, 111)
    sspr(1, 88, 4, 6, 37, 111)

    sspr_rect(br, 6, 111)
    sspr_rect(br, 33, 111, true)
    sspr_rect(br, 42, 111)
    sspr_rect(br, 69, 111, true)

    if state then
        draw_hud_slot(state.equipped_a, 6, 111, 29, 14)
        draw_hud_slot(state.equipped_b, 42, 111, 29, 14)
    end

    sspr(8, 81, 7, 7, 73, 111)

    local qty = mid(0, p_stats and p_stats.rupees or 0, 999)
    spr(hud_digits[flr(qty / 100) + 1], 72, 118)
    spr(hud_digits[flr((qty % 100) / 10) + 1], 80, 118)
    spr(hud_digits[(qty % 10) + 1], 88, 118)

    for i=0, 3 do
        local htop = (state and state.hearts and state.hearts[i+1]) and hf or he
        local hbot = (state and state.hearts and state.hearts[i+5]) and hf or he
        sspr_rect(htop, 96+i*8, 111)
        sspr_rect(hbot, 96+i*8, 119)
    end

    camera(cx, cy)
end

function current_panim_sprite()
    local total_frames = max(#panim, 1)
    return panim[mid(1, panim_frame, total_frames)]
end

function get_attack_phase()
    return mid(1, flr(pattack_timer/5)+1, 3)
end

function draw_defend()
    if pstate != PSTATE.DEFEND or not equipament.shield.equipped then return end
end

-- retorna a hitbox da espada em pixels (x,y,w,h)
function get_sword_hitbox()
    if pstate != PSTATE.ATTACK or not equipament.sword.equipped then return 0,0,0,0 end
    local f = sword_frames[(pdir-1)*3 + get_attack_phase()]
    return px + f[6], py + f[7], f[8], f[9]
end

function draw_attack(dir)
    if not equipament.sword.equipped then return end
    local f = sword_frames[(dir-1)*3 + get_attack_phase()]
    sspr_rect(items_size.sword[f[1]], px + f[2], py + f[3], f[4]==1, f[5]==1)
end

function draw_walk_with_shield()
    if not equipament.shield.equipped or pstate==PSTATE.ATTACK or pstate==PSTATE.PICKUP or pstate==PSTATE.PUSH then return end

    local s = items_size.shield
    local sh_data = nil
    local offpx, offpy = 0, 0
    local step = (psx != 0 or psy != 0) and ((flr(timer_frame/8) % 2) + 1) or 1

    if pdir == 4 then
        sh_data = s.down[step]
        offpx, offpy = 0, 1 + step
    elseif pdir == 3 then
        sh_data = s.up[step]
        offpx, offpy = 12, 4 + step
    elseif pdir == 2 then
        sh_data = s.right
        offpx, offpy = step, 8
    end

    if sh_data then
        sspr_rect(sh_data, px + offpx, py + offpy)
    end
end

function draw_pickup_item()
    if pstate != PSTATE.PICKUP or pickup_item_kind == nil then return end
    local d = get_item_sprdata(pickup_item_kind)
    sspr_rect(d, px + 8 - flr(d.sw / 2), py - d.sh - 2)
end

function draw_player()
    local spr_id = current_panim_sprite()
    local flip = (pstate == PSTATE.DEFEND) and false or pflipx

    if pdir == 3 then
        if pstate != PSTATE.DEFEND then draw_walk_with_shield() end
        if pstate == PSTATE.ATTACK then draw_attack(pdir) end
    end

    spr(spr_id, px, py, 2, 2, flip)
    draw_pickup_item()

    if pdir != 3 then
        if pstate != PSTATE.DEFEND then draw_walk_with_shield() end
        if pstate == PSTATE.ATTACK then draw_attack(pdir) end
    end

    draw_defend()
end
