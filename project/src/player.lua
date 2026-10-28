-- estados do player
PSTATE = {
    IDLE=0,
    WALK=1,
    ATTACK=2,
    DEFEND=3,
    HURT=4,
    PICKUP=5,
    PUSH=6,
}

-- direcoes: 1=left, 2=right, 3=up, 4=down (alinhadas com btn 0..3)
dir_dx = {-1, 1, 0, 0}
dir_dy = {0, 0, -1, 1}

function player_init()
    px = 64
    py = 64

    p_stats = {
        hp = 3,
        max_hp = 3,
        rupees = 0,
        keys = 0,
    }

    -- indexadas por direcao: 1=left, 2=right, 3=up, 4=down
    animation = {
        walk    = {{169,171}, {169,171}, {173},    {167}},
        push    = {{8,10},    {8,10},    {4,6},    {0,2}},
        defend  = {{72,74},   {76,78},   {68,70},  {64,66}},
        attack  = {{104,106}, {104,106}, {100,102},{96,98}},
        pick_up = {204}
    }

    col_dirs = {
        {4,9,4,12},   -- 1: left
        {11,9,11,12}, -- 2: right
        {6,7,9,7},    -- 3: up
        {6,15,9,15}   -- 4: down
    }
    col = col_dirs[4]

    panim_timer = 0
    panim_frame = 1
    panim = animation.walk[4]

    last_btn = 0
    timer_frame = 0

    pflipx = false
    pdir = 4
    pdefdir = 4
    pstate = PSTATE.IDLE
    pattack_timer = 0

    ppickup_timer = 0
    PICKUP_DURATION = 90

    psx = 0
    psy = 0
end

function start_pickup()
    set_pstate(PSTATE.PICKUP)
    set_panim(animation.pick_up)
    ppickup_timer = 0
    psx = 0
    psy = 0
end

function update_pickup()
    ppickup_timer += 1
    if ppickup_timer >= PICKUP_DURATION then
        set_pstate(PSTATE.IDLE)
        set_panim(animation.walk[pdir])
    end
end

function set_panim(anim)
    if panim != anim then
        panim = anim
        panim_frame = 1
        panim_timer = 0
    end
end

function set_pstate(s)
    if pstate != s then
        pstate = s
        panim_frame = 1
        panim_timer = 0
        pattack_timer = 0
    end
end

function player_move()
    px += psx
    py += psy
end

function player_animation()
    local total = max(#panim, 1)

    panim_timer += 1
    if panim_timer >= 8 then
        panim_timer = 0
        panim_frame += 1
    end

    if panim_frame > total then
        panim_frame = 1
    end
end

function update_pflipx(moving)
    if pstate == PSTATE.DEFEND then
        pflipx = false
    elseif pstate == PSTATE.PUSH then
        pflipx = (pdir == 3 and flr(timer_frame/8)%2 == 1) or (pdir == 2)
    elseif pdir >= 3 and moving then
        pflipx = (flr(timer_frame/8)%2 == 1)
    elseif pdir <= 2 then
        pflipx = (pdir == 2)
    end
end

function update_idle()
    panim_timer = 0
    panim_frame = 1
    set_panim(animation.walk[pdir])
end

-- retorna true se o player se moveu efetivamente neste frame
function update_walk(press)
    local moved = false

    if press >= 2 then
        psx *= 0.7
        psy *= 0.7
    end

    if last_btn != btn() then
        px = flr(px)
        py = flr(py)
    end

    local no_col = check_move(psx, psy)

    if not no_col then
        if press == 1 then
            local slpx = psx == 0 and 1 or 0
            local slpy = psy == 0 and 1 or 0
            local j = 1
            repeat
                for i=1,3 do
                    local sdx = psx + slpx*i*j
                    local sdy = psy + slpy*i*j
                    if check_move(sdx, sdy) then
                        psx = sgn(sdx)
                        psy = sgn(sdy)
                        no_col = true
                        break
                    end
                end
                j -= 2
            until no_col or j < -1

        elseif press >= 2 then
            if check_move(psx, 0) then
                psy = 0
                psx /= 0.7
                no_col = true
            elseif check_move(0, psy) then
                psx = 0
                psy /= 0.7
                no_col = true
            end
        end
    end

    if no_col then
        player_move()
        moved = true
    end

    return moved
end

function update_attack()
    pattack_timer += 1
    if pattack_timer >= 15 then
        set_pstate(PSTATE.IDLE)
        set_panim(animation.walk[pdir])
    end
end

function update_defend(press)
    set_panim(animation.defend[pdefdir])
    if press > 0 then
        update_walk(press)
    else
        panim_timer = 0
        panim_frame = 1
    end
end

function check_buttons()
    local press = 0
    psx = 0
    psy = 0

    if pstate == PSTATE.PICKUP then
        update_pickup()
        player_animation()
        return
    end

    for i=1,4 do
        if btn(i-1) then
            psx += dir_dx[i]
            psy += dir_dy[i]
            col = col_dirs[i]
            press += 1
            if pstate != PSTATE.DEFEND then
                pdir = i
                if pstate != PSTATE.ATTACK and pstate != PSTATE.PUSH then
                    pflipx = (i == 2)
                    set_panim(animation.walk[i])
                end
            end
        end
    end

    local sword_pressed = (state.equipped_a == "sword" and btnp(4)) or (state.equipped_b == "sword" and btnp(5))
    local shield_held   = (state.equipped_a == "shield" and btn(4)) or (state.equipped_b == "shield" and btn(5))

    if sword_pressed and pstate != PSTATE.DEFEND and equipament.sword.equipped then
        set_pstate(PSTATE.ATTACK)
        set_panim(animation.attack[pdir])
    end

    if shield_held and pstate != PSTATE.ATTACK and pstate != PSTATE.PUSH and equipament.shield.equipped then
        if pstate != PSTATE.DEFEND then
            pdefdir = pdir
            set_pstate(PSTATE.DEFEND)
            set_panim(animation.defend[pdefdir])
        end
    elseif pstate == PSTATE.DEFEND then
        for i=1,4 do
            if btn(i-1) then pdir = i end
        end
        set_pstate(PSTATE.IDLE)
        set_panim(animation.walk[pdir])
    end

    if pstate == PSTATE.ATTACK then
        update_attack()
    elseif pstate == PSTATE.DEFEND then
        update_defend(press)
    elseif press > 0 then
        if pstate != PSTATE.PUSH then
            set_pstate(PSTATE.WALK)
        end

        if not update_walk(press) then
            set_pstate(PSTATE.PUSH)
            set_panim(animation.push[pdir])
        else
            set_pstate(PSTATE.WALK)
            set_panim(animation.walk[pdir])
        end
    else
        set_pstate(PSTATE.IDLE)
        update_idle()
    end

    update_pflipx(press > 0)
    player_animation()
    last_btn = btn()
end
