function unpack_rect(s)
    local v = split(s)
    return {sx=v[1], sy=v[2], sw=v[3], sh=v[4]}
end

function unpack_rects(str)
    local t = {}
    for e in all(split(str, "|")) do
        local v = split(e)
        t[v[1]] = {sx=v[2], sy=v[3], sw=v[4], sh=v[5]}
    end
    return t
end

function unpack_items(str)
    local t = {}
    for e in all(split(str, "|")) do
        local v = split(e)
        t[v[1]] = {
            equipped = false,
            picked = false,
            qty = 0,
            spr = {sx=v[2], sy=v[3], sw=v[4], sh=v[5]}
        }
    end
    return t
end

brackets_selector = unpack_rect("6,65,28,14")
page_arrow = unpack_rect("106,52,10,10")
numbers = split("160,161,162,163,164,176,177,178,179,180")

instruments = {
    empty_slot = 13,
    moon_cello = 32, conch_horn = 34, lilly_bell = 36, surf_harp = 38,
    wind_marimba = 40, coral_triangle = 42, calm_organ = 44, thunder_drum = 46
}

separator = unpack_rects("hor,96,12,7,3|ver,100,1,3,7")

pick_up = unpack_items("arrow,104,16,8,15|guardian_acorn,112,16,8,15|power_piece,92,16,12,12|recovery_heart,113,97,7,7|rupee,121,17,7,14")

equipament = unpack_items("sword,0,0,8,16|shield,91,0,8,10|bow,16,0,6,14|hookshot,45,0,7,16|shovel,52,0,9,14|bomb,37,0,8,13|boomerang,75,0,8,12|magic_rod,68,0,7,15|ocarina,61,0,7,15|magic_powder,83,0,8,14|pegasus_boots,29,0,8,14|bracelet,8,0,8,14|feather,22,0,7,16|sleepy_toadstool,120,80,10,11")

non_equippable = unpack_items("flippers,96,80,8,15|golden_leaf,88,80,8,15|heart_piece,96,96,16,15|secret_medicine,104,80,8,16|secret_seashell,112,80,8,14")

dungeon_items = unpack_items("heart_container,81,98,14,12|stone_slab,88,112,8,13|map,120,112,8,14|compass,112,112,8,15|small_key,104,112,7,13|nightmare_key,96,112,8,14")

keys = unpack_items("tail_key,0,32,8,15|slime_key,32,32,8,15|angler_key,8,32,8,15|face_key,16,32,8,15|bird_key,24,32,8,15")

trading_sequence = unpack_items("yoshi_doll,40,32,13,15|ribbon,53,32,16,14|dog_food,69,32,11,14|bananas,80,32,16,15|honeycomb,96,32,14,15|stick,110,32,6,15|pineapple,116,32,12,15|necklace,0,50,16,14|magnifying_lens,16,49,15,15|broom,31,49,12,15|goat_letter,43,51,14,13|hibiscus,57,49,12,15|mermaid_scale,69,52,8,12|fishing_hook,77,49,12,15|pink_bra,89,52,16,12")
