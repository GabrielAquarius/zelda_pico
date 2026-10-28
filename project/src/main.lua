in_inventory = false

function toggle_inventory()
    in_inventory = not in_inventory
    if in_inventory then
        reload(0x0, 0x0, 0x2000, "inventory.p8")
        menuitem(1, "back to game", toggle_inventory)
    else
        reload(0x0, 0x0, 0x2000)
        menuitem(1, "inventory", toggle_inventory)
    end
end

function _init()
    palt(0, false)
    palt(14, true)
    poke(0x5f2e, 1)
    -- pal({[0]=128, 3, 139, 138}, 1) Try to use gameboy colors
    pal(11, 11+128, 1)
    pal(2, 3+128, 1)

    player_init()
    items_init()
    inventory_init()
    load_room(1)

    menuitem(1, "inventory", toggle_inventory)
end

function _draw()
    if in_inventory then
        draw_inventory()
        return
    end

    cls(7)
    draw_map()
    draw_hud()
    draw_world_items()
    draw_player()
    draw_bushes()
end

-- rotaciona os 4 frames de animacao (sprites 37..40) direto na VRAM
function animate_vram_tiles()
    for i=0,7 do
        local a = 0x0414 + i*64
        memcpy(0x4300, a, 4)
        memcpy(a, a+4, 12)
        memcpy(a+12, 0x4300, 4)
    end
end

function _update60()
    if in_inventory then
        update_inventory()
        return
    end

    update_transition()
    update_bushes()

    if not transition.active then
        check_room_exit()
        check_buttons()
        check_item_collision()
        check_sword_bush()
        update_camera()
    end

    timer_frame += 1
    if timer_frame % 20 == 0 then
        animate_vram_tiles()
    end
end
