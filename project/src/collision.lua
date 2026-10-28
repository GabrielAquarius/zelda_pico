function check_move(dx,dy)
    local newx=px+dx
    local newy=py+dy

    if newy+col[4] >= ROOM_HEIGHT then
        return false
    end

    points={
        {newx+col[1],newy+col[2],7},
        {newx+col[3],newy+col[4],7}
    }
    for p in all(points) do
        if not walkable(p[1],p[2]) then
            p[3]=8
            return false
        end
    end
    return true
end

function walkable(pnx,pny)
    my_tile=mget(pnx/8,pny/8)
    return not fget(my_tile,0)
end
