-- estados do player
PSTATE={
    IDLE=0,
    WALK=1,
    ATTACK=2,
    DEFEND=3,
    HURT=4,
    PICKUP=5,
    PUSH=6,
}

function player_init()
    px=64
    py=64

    p_stats = {
        hp = 9,
        max_hp = 9,
        rupees = 0,
        keys = 0,
    }

    animation={
        walk={
            down={2},
            side={4,6},
            up={8}
        },
        pick_up = {10},
        attack={
            down={37,39},
            up={41,43},
            side={45,64}
        },
        defend={
            down={66,68},
            up={70,72},
            left={74,76},
            right={78,96}
        },
        push={
            down={100,102},
            up={104, 106},
            side={108,110}
        }
    }

    col_left={4,9,4,12}
    col_right={11,9,11,12}
    col_up={6,7,9,7}
    col_down={6,15,9,15}
    col=col_down

    panim_timer=0
    panim_frame=1
    panim=animation.walk.down

    last_btn=0
    timer_frame=0

    pflipx=false
    pdir="down"
    pdefdir="down"
    pstate=PSTATE.IDLE
    pattack_timer=0

    ppickup_timer = 0
    PICKUP_DURATION = 90

    psx=0
    psy=0
end

-- helpers de animação por direção
function get_walk_anim(dir)
    if dir=="up" then return animation.walk.up
    elseif dir=="down" then return animation.walk.down
    else return animation.walk.side
    end
end

function get_push_anim(dir)
    if dir=="up" then return animation.push.up
    elseif dir=="down" then return animation.push.down
    else return animation.push.side
    end
end

function get_defend_anim(dir)
    if dir=="up" then return animation.defend.up
    elseif dir=="down" then return animation.defend.down
    elseif dir=="left" then return animation.defend.left
    else return animation.defend.right
    end
end

function get_attack_anim(dir)
    if dir=="up" then return animation.attack.up
    elseif dir=="down" then return animation.attack.down
    else return animation.attack.side
    end
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
        set_panim(get_walk_anim(pdir))
    end
end

function set_panim(anim)
    if panim!=anim then
        panim=anim
        panim_frame=1
        panim_timer=0
    end
end

function set_pstate(s)
    if pstate!=s then
        pstate=s
        panim_frame=1
        panim_timer=0
        pattack_timer=0
    end
end

function player_move()
    px+=psx
    py+=psy
end

function player_animation()
    local total=max(#panim,1)

    panim_timer+=1
    if panim_timer>=8 then
        panim_timer=0
        panim_frame+=1
        if panim_frame>total then
            panim_frame=1
        end
    end

    if panim_frame>total then
        panim_frame=1
    end
end

function update_pflipx(moving)
    if pstate==PSTATE.DEFEND then
        pflipx=false
        return
    end

    -- flip durante empurrar
    if pstate==PSTATE.PUSH then
        if pdir=="up" then
            -- alterna para simular troca de braços
            pflipx=(flr(timer_frame/8)%2==1)
        elseif pdir=="left" then
            -- sprite já está no lado correto, sem flip
            pflipx=false
        elseif pdir=="right" then
            -- espelha sempre (ambos os frames)
            pflipx=true
        else
            pflipx=false -- down
        end
        return
    end

    if (pdir=="up" or pdir=="down") and moving then
        pflipx=(flr(timer_frame/8)%2==1)
    else
        if pdir=="left" then pflipx=false end
        if pdir=="right" then pflipx=true end
    end
end

function update_idle()
    panim_timer=0
    panim_frame=1
    set_panim(get_walk_anim(pdir))
end

-- retorna true se o player se moveu efetivamente neste frame
function update_walk(press)
    local moved=false

    if press>=2 then
        psx=psx*0.7
        psy=psy*0.7
    end

    if last_btn!=btn() then
        px=flr(px)
        py=flr(py)
    end

    local no_col=check_move(psx,psy)

    if not no_col then
        if press==1 then
            local slpx=psx==0 and 1 or 0
            local slpy=psy==0 and 1 or 0
            local j=1
            repeat
                for i=1,3 do
                    local sdx=psx+slpx*i*j
                    local sdy=psy+slpy*i*j
                    if check_move(sdx,sdy) then
                        psx=sgn(sdx)
                        psy=sgn(sdy)
                        no_col=true
                        break
                    end
                end
                j-=2
            until no_col or j<-1

        elseif press>=2 then
            if check_move(psx,0) then
                psy=0
                psx=psx/0.7
                no_col=true
            elseif check_move(0,psy) then
                psx=0
                psy=psy/0.7
                no_col=true
            end
        end
    end

    if no_col then
        player_move()
        moved=true
    end

    return moved
end

function update_attack()
    pattack_timer+=1
    if pattack_timer>=15 then
        set_pstate(PSTATE.IDLE)
        set_panim(get_walk_anim(pdir))
    end
end

function update_defend(press)
    set_panim(get_defend_anim(pdefdir))
    if press > 0 then
        update_walk(press)
    else
        panim_timer = 0
        panim_frame = 1
    end
end

function check_buttons()
    local press=0
    psx=0
    psy=0

    if pstate == PSTATE.PICKUP then
        update_pickup()
        player_animation()
        return
    end

    if btn(0) then
        psx=-1
        col=col_left
        press+=1
        if pstate!=PSTATE.DEFEND then
            pdir="left"
            if pstate!=PSTATE.ATTACK and pstate!=PSTATE.PUSH then
                pflipx=false
                set_panim(animation.walk.side)
            end
        end
    elseif btn(1) then
        psx=1
        col=col_right
        press+=1
        if pstate!=PSTATE.DEFEND then
            pdir="right"
            if pstate!=PSTATE.ATTACK and pstate!=PSTATE.PUSH then
                pflipx=true
                set_panim(animation.walk.side)
            end
        end
    end

    if btn(2) then
        psy=-1
        col=col_up
        press+=1
        if pstate!=PSTATE.DEFEND then
            pdir="up"
            if pstate!=PSTATE.ATTACK and pstate!=PSTATE.PUSH then
                pflipx=false
                set_panim(animation.walk.up)
            end
        end
    elseif btn(3) then
        psy=1
        col=col_down
        press+=1
        if pstate!=PSTATE.DEFEND then
            pdir="down"
            if pstate!=PSTATE.ATTACK and pstate!=PSTATE.PUSH then
                pflipx=false
                set_panim(animation.walk.down)
            end
        end
    end

    if btnp(4) and pstate!=PSTATE.DEFEND and inv.sword==1 then
        set_pstate(PSTATE.ATTACK)
        set_panim(get_attack_anim(pdir))
    end

    if btn(5) and pstate!=PSTATE.ATTACK and pstate!=PSTATE.PUSH and inv.shield==1 then
        if pstate!=PSTATE.DEFEND then
            pdefdir=pdir
            set_pstate(PSTATE.DEFEND)
            set_panim(get_defend_anim(pdefdir))
        end
    else
        if pstate==PSTATE.DEFEND then
            if btn(0) then pdir="left"
            elseif btn(1) then pdir="right" end
            if btn(2) then pdir="up"
            elseif btn(3) then pdir="down" end

            set_pstate(PSTATE.IDLE)
            set_panim(get_walk_anim(pdir))
        end
    end

    if pstate==PSTATE.ATTACK then
        update_attack()
    elseif pstate==PSTATE.DEFEND then
        update_defend(press)
    elseif press>0 then
        -- tenta andar; se bloqueado, vira PUSH
        local prev_state=pstate
        if pstate!=PSTATE.PUSH then
            set_pstate(PSTATE.WALK)
        end

        local moved=update_walk(press)

        if not moved then
            -- colidiu na direção pressionada -> empurrando
            if pstate!=PSTATE.PUSH then
                set_pstate(PSTATE.PUSH)
            end
            set_panim(get_push_anim(pdir))
        else
            -- andou normalmente -> garante walk
            if pstate==PSTATE.PUSH then
                set_pstate(PSTATE.WALK)
            end
            set_panim(get_walk_anim(pdir))
        end
    else
        set_pstate(PSTATE.IDLE)
        update_idle()
    end

    update_pflipx(press>0)
    player_animation()
    last_btn=btn()
end