rooms = {
    [1] = {
        exits = {right=2},
        items = {
            {x=40,  y=40,  kind="sword",   collected=false},
            {x=80,  y=40,  kind="shield",  collected=false},
            {x=100, y=80,  kind="heart",   collected=false},
            {x=60,  y=100, kind="crystal", collected=false},
        }
    },
    [2] = {
        exits = {left=1},
        items = {},
        bushes = {
            {tx=4, ty=4},
            {tx=8, ty=7},
        }
    },
}

current_room_id = 1
world_items = {}

cam = {x=0, y=0}

DIR = {right=1, left=2, down=3, up=4}

transition = {
    active = false,
    dir = nil,
    progress = 0,
    speed = 4,
    offset_x = 0,
    offset_y = 0,
    next_id = nil,
}

ROOM_WIDTH  = 160
ROOM_HEIGHT = 128
VIEWPORT_W  = 128
VIEWPORT_H  = 108

local EDGE_MARGIN_X = 2
local EDGE_MARGIN_Y = 2

function get_room_data(id)
    return rooms[id]
end

function write_room_to_vram(id)
    local room = get_room_data(id)
    if not room then return end

    for ty=0,15 do
        for tx=0,19 do
            local border = (ty==0 or ty==15 or (id==1 and tx==0) or (id==2 and tx==19))
            mset(tx, ty, border and 1 or 0)
        end
    end
    if id == 1 then mset(6, 0, 203) end
end

function load_room(id)
    current_room_id = id
    write_room_to_vram(id)
    cam.x = 0
    cam.y = 0
    camera(0, 0)

    local room = get_room_data(id)
    world_items = room.items
    load_bushes(room.bushes)
end

function start_transition(dir, next_id)
    transition.active = true
    transition.dir = dir
    transition.progress = 0
    transition.offset_x = 0
    transition.offset_y = 0
    transition.next_id = next_id
    psx = 0
    psy = 0
end

function update_transition()
    if not transition.active then return end

    local spd = transition.speed
    transition.progress += spd

    if transition.dir == DIR.right then
        transition.offset_x += spd
    elseif transition.dir == DIR.left then
        transition.offset_x -= spd
    elseif transition.dir == DIR.down then
        transition.offset_y += spd
    elseif transition.dir == DIR.up then
        transition.offset_y -= spd
    end

    camera(transition.offset_x, transition.offset_y)

    local target = (transition.dir == DIR.up or transition.dir == DIR.down) and ROOM_HEIGHT or 128

    if transition.progress >= target then
        finish_transition()
    end
end

function finish_transition()
    local dir = transition.dir
    local next_id = transition.next_id

    if dir == DIR.right then
        px = EDGE_MARGIN_X + 1
    elseif dir == DIR.left then
        px = ROOM_WIDTH - EDGE_MARGIN_X - 1
    elseif dir == DIR.down then
        py = EDGE_MARGIN_Y + 1
    elseif dir == DIR.up then
        py = ROOM_HEIGHT - EDGE_MARGIN_Y - 1
    end

    load_room(next_id)

    transition.active = false
    transition.progress = 0
    transition.offset_x = 0
    transition.offset_y = 0
    transition.dir = nil
    transition.next_id = nil
end

function draw_map()
    map(0, 0, 0, 0, 20, 16)
end

function update_camera()
    if transition.active then return end

    cam.x = mid(0, px - 64, ROOM_WIDTH  - VIEWPORT_W)
    cam.y = mid(0, py - 54, ROOM_HEIGHT - VIEWPORT_H)

    camera(cam.x, cam.y)
end

function check_room_exit()
    if transition.active then return end

    local room = get_room_data(current_room_id)
    if not room then return end
    if px >= ROOM_WIDTH - EDGE_MARGIN_X and room.exits.right then
        start_transition(DIR.right, room.exits.right)
    elseif px <= EDGE_MARGIN_X and room.exits.left then
        start_transition(DIR.left, room.exits.left)
    elseif py >= ROOM_HEIGHT - EDGE_MARGIN_Y and room.exits.down then
        start_transition(DIR.down, room.exits.down)
    elseif py <= EDGE_MARGIN_Y and room.exits.up then
        start_transition(DIR.up, room.exits.up)
    end
end
