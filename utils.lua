function perspective(x, y, h)
    local xm = x - BAT_MIN_X
    local ym = y - (BAT_MIN_Y + BAT_MAX_Y)/2
    local s = PROJ_S
    local d = PROJ_D
    local cx = PROJ_CX
    local cy = PROJ_CY
    if xm < 1 then xm = 1 end
    local screen_x = s * (ym + d / xm) + cx
    local screen_y = s * (h + d / xm) + cy
    return screen_x, screen_y
end
