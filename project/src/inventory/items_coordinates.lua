brackets_selector = {x=6, y=65, w=28, h=14}

numbers = {
    zero = 160,
    one = 161,
    two = 162,
    three = 163,
    four = 164,
    five = 176,
    six = 177,
    seven = 178,
    eight = 189,
    nine = 180
}

instruments = {
    moon_cello = 32,
    conch_horn = 33,
    lilly_bell = 34,
    surf_harp = 35,
    wind_marimba = 36,
    coral_triangle = 37,
    calm_organ = 38,
    thunder_drum = 39
}

separator = {
    hor = {sx=96, sy=12, sw=7, sh=3},
    ver = {sx=100, sy=1, sw=3, sh=7}
}

pick_up = {
    arrow = {
        picked = false,
        qty = 0,
        spr = {sx=104, sy=16, sw=8, sh=15}
    },
    guardian_acorn={
        kill_qty = 0,
        spr = {sx=112, sy=16, sw=8, sh=15}
    },
    power_piece = {
        kill_qty = 0,
        spr = {sx=92, sy=16, sw=12, sh=12}
    },
    recovery_heart = {
        picked = false,
        spr = {sx=112, sy=9, sw=7, sh=7}
    },
    rupee = {
        picked = false,
        qty = 0,
        spr = {sx=121, sy=17, sw=7, sh=14}
    },
}

equipament = {
    sword = {
        equipped = false,
        level = {lvl=1},
        spr = {sx=0, sy=0, sw=8, sh=16},
    },
    shield = {
        equipped = false,
        level = {},
        spr = {sx=91, sy=0, sw=8, sh=10},
    },
    bow = {
        equipped = false,
        spr = {sx=16, sy=0, sw=6, sh=14},
        qty = pick_up.arrow.qty
    },
    hookshot = {
        equipped = false,
        spr = {sx=45, sy=0, sw=7, sh=16},
    },
    shovel = {
        equipped = false,
        spr = {sx=56, sy=0, sw=8, sh=14},
    },
    bomb = {
        equipped = false,
        spr = {sx=37, sy=0, sw=8, sh=13},
    },
    boomerang = {
        equipped = false,
        spr = {sx=81, sy=0, sw=8, sh=12},
    },
    magic_rod = {
        equipped = false,
        spr = {sx=74, sy=0, sw=7, sh=15},
    },
    ocarina = {
        equipped = false,
        spr = {sx=65, sy=0, sw=8, sh=14},
    },
    magic_powder = {
        equipped = false,
        spr = {sx=83, sy=0, sw=8, sh=14},
        qty = 0
    },
    pegasus_boots = {
        equipped = false,
        spr = {sx=29, sy=0, sw=8, sh=14},
    },
    bracelet = {
        equipped = false,
        spr = {sx=8, sy=0, sw=8, sh=14},
    },
    feather = {
        equipped = false,
        spr = {sx=22, sy=0, sw=7, sh=16},
    }
}

non_equipable = {
    flippers = {
        equipped = false,
        spr = {sx=98, sy=48, sw=8, sh=15},
    },
    golder_leaf = {
        picked = false,
        spr = {sx=89, sy=48, sw=8, sh=15},
        qty=0
    },
    heart_piece = {
        picked = false,
        spr = {sx=96, sy=96, sw=16, sh=15},
        qty=0
    },
    secret_medicine = {
        equipped = false,
        spr = {sx=105, sy=48, sw=8, sh=16},
    },
    secret_seashell = {
        equipped = false,
        spr = {sx=112, sy=48, sw=8, sh=14},
    },
    sleepy_toadstool = {
        equipped = false,
        spr = {sx=120, sy=48, sw=10, sh=11},
    },
}

dungeon_items = {
    heart_container = {
        equipped = false,
        spr = {sx=81, sy=98, sw=14, sh=12},
    },
    stone_slab = {
        equipped = false,
        spr = {sx=88, sy=112, sw=8, sh=13},
    },
    map = {
        equipped = false,
        spr = {sx=120, sy=112, sw=8, sh=14},
    },
    compass = {
        equipped = false,
        spr = {sx=112, sy=112, sw=8, sh=15},
    },
    small_key = {
        equipped = false,
        spr = {sx=104, sy=112, sw=7, sh=13},
        quantity = 0
    },
    nightmare_key = {
        equipped = false,
        spr = {sx=96, sy=112, sw=8, sh=14},
    }
}

keys = {
    tail_key = {
        equipped = false,
        spr = {sx=0, sy=32, sw=8, sh=15},
    },
    slime_key = {
        equipped = false,
        spr = {sx=32, sy=32, sw=8, sh=15},
    },
    angler_key = {
        equipped = false,
        spr = {sx=8, sy=32, sw=8, sh=15},
    },
    face_key = {
        equipped = false,
        spr = {sx=16, sy=32, sw=8, sh=15},
    },
    bird_key = {
        equipped = false,
        spr = {sx=24, sy=32, sw=8, sh=15},
    },
}

trading_sequence ={
    yoshi_doll = {
        picked = false,
        spr = {sx=40, sy=32, sw=13, sh=15},
    },
    ribbon = {
        picked = false,
        spr = {sx=53, sy=32, sw=16, sh=14},
    },
    dog_food = {
        picked = false,
        spr = {sx=69, sy=32, sw=11, sh=14},
    },
    bananas = {
        picked = false,
        spr = {sx=80, sy=32, sw=16, sh=15},
    },
    honeycomb = {
        picked = false,
        spr = {sx=96, sy=32, sw=14, sh=15},
    },
    stick = {
        picked = false,
        spr = {sx=110, sy=32, sw=6, sh=15},
    },
    pineapple = {
        picked = false,
        spr = {sx=116, sy=32, sw=12, sh=15},
    },
    necklace = {
        picked = false,
        spr = {sx=0, sy=50, sw=16, sh=14},
    },
    magnifying_lens = {
        picked = false,
        spr = {sx=16, sy=49, sw=15, sh=15},
    },
    broom = {
        picked = false,
        spr = {sx=31, sy=49, sw=12, sh=15},
    },
    goat_letter = {
        picked = false,
        spr = {sx=43, sy=51, sw=14, sh=13},
    },
    hibiscus = {
        picked = false,
        spr = {sx=57, sy=49, sw=12, sh=15},
    },
    mermaid_scale = {
        picked = false,
        spr = {sx=69, sy=52, sw=8, sh=12},
    },
    fishing_hook = {
        picked = false,
        spr = {sx=77, sy=49, sw=12, sh=15},
    },
    pink_bra = {
        picked = false,
        spr = {sx=89, sy=52, sw=16, sh=12},
    }
}