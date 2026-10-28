function items_init()
    items_size = {
        shield = {
            down = {unpack_rect("113,66,4,13"), unpack_rect("117,66,4,13")},
            up   = {unpack_rect("97,55,4,9"),   unpack_rect("124,72,4,8")},
            right = unpack_rect("121,64,6,7")
        },
        sword = unpack_rects("ver,121,82,5,14|hor,97,48,14,5|diag,113,49,14,14")
    }

    world_item_spr = unpack_rects("shield,0,64,8,10|sword,8,64,8,16|heart,112,9,7,7|crystal,121,17,7,14")

    inv = {
        sword = 0,
        shield = 0,
        bow = 0,
        hookshot = 0
    }

    world_items = {}
    pickup_item_kind = nil
end

function rects_overlap(ax,ay,aw,ah, bx,by,bw,bh)
    return ax<bx+bw and ax+aw>bx and ay<by+bh and ay+ah>by
end

function get_item_sprdata(kind)
    return world_item_spr[kind]
end

function check_item_collision()
    if pstate==PSTATE.PICKUP or pstate==PSTATE.ATTACK then return end

    for item in all(world_items) do
        if not item.collected then
            local idata = get_item_sprdata(item.kind)
            if rects_overlap(px+4, py+6, 8, 10, item.x, item.y, idata.sw, idata.sh) then
                collect_item(item)
            end
        end
    end
end

function collect_item(item)
    item.collected = true
    local k = item.kind

    if k=="sword" or k=="shield" then
        inv[k] = 1
        if add_item_to_inventory then add_item_to_inventory(k) end
        pickup_item_kind = k
        start_pickup()
    elseif k=="heart" then
        p_stats.hp = min(p_stats.hp + 1, 8)
        if sync_hearts_from_stats then sync_hearts_from_stats() end
    elseif k=="crystal" then
        p_stats.rupees += 1
        if pick_up and pick_up.rupee then
            pick_up.rupee.qty = p_stats.rupees
        end
    end
end

function draw_world_items()
    for item in all(world_items) do
        if not item.collected then
            sspr_rect(get_item_sprdata(item.kind), item.x, item.y)
        end
    end
end
