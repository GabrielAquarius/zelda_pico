function _init()
    palt(0,false)
    palt(14,true)
    poke(0x5f2e,1)
    -- pal({[0]=128, 3, 139, 138}, 1) Try to use gameboy colors
    pal(11,11+128,1)
    pal(2,3+128,1)

    player_init()
    items_init()
    load_room(1)
end

function _draw()
    cls(7)
    draw_map()
    draw_hud()
    draw_world_items()
    draw_player()
    draw_bushes()
end

function _update60()
    update_transition()
    update_bushes()

    if not transition.active then
        check_room_exit()
        check_buttons()
        check_item_collision()
        check_sword_bush()
        update_camera() 
    end

    timer_frame+=1
    if timer_frame%20==0 then
        for x=0,15 do
            for y=0,15 do
                local tle=mget(x,y)
                if tle>=37 and tle<=39 then
                    mset(x,y,tle+1)
                elseif tle==40 then
                    mset(x,y,37)
                end
            end
        end
    end
end