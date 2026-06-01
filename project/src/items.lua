function items_init()
    items_size = {
        shield_collectable = {sx=0,  sy=8,  sw=8, sh=10},
        shield = {
            down = {{sx=0, sy=18, sw=4, sh=13}, {sx=4, sy=18, sw=3, sh=13}},
            up = {{sx=120, sy=23, sw=4, sh=9}, {sx=124, sy=23, sw=4, sh=8}},
            right = {sx=8, sy=24, sw=6, sh=7}
        },
        sword_collectable = {sx=120, sy=0, sw=8, sh=16},
        sword = {
            ver = {sx=9, sy=0, sw=5,  sh=14},
            hor = {sx=10, sy=16, sw=14, sh=5},
            diag = {sx=25, sy=17, sw=14, sh=14}
        },
        heart = {sx=64, sy=96, sw=7, sh=7},
        crystal = {sx=80, sy=97, sw=7, sh=14}
    }

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

function check_item_collision()
    if pstate==PSTATE.PICKUP or pstate==PSTATE.ATTACK then return end

    local phx = px+4
    local phy = py+6
    local phw = 8
    local phh = 10

    for item in all(world_items) do
        if not item.collected then
            local idata = get_item_sprdata(item.kind)
            if rects_overlap(phx,phy,phw,phh, item.x,item.y,idata.sw,idata.sh) then
                collect_item(item)
            end
        end
    end
end

function get_item_sprdata(kind)
    if kind=="sword" then return items_size.sword_collectable end
    if kind=="shield" then return items_size.shield_collectable end
    if kind=="heart" then return items_size.heart end
    if kind=="crystal" then return items_size.crystal end
end

function collect_item(item)
    item.collected = true

    if item.kind=="sword" then
        inv.sword = 1
        pickup_item_kind = "sword"
        start_pickup()
    elseif item.kind=="shield" then
        inv.shield = 1
        pickup_item_kind = "shield"
        start_pickup()
    elseif item.kind=="heart" then
        p_stats.hp = min(p_stats.hp + 3, p_stats.max_hp)
    elseif item.kind=="crystal" then
        p_stats.rupees += 1
    end
end

function draw_world_items()
    for item in all(world_items) do
        if not item.collected then
            local d = get_item_sprdata(item.kind)
            sspr(d.sx, d.sy, d.sw, d.sh, item.x, item.y)
        end
    end
end