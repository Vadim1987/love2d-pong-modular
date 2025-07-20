-- Perspective transform: projects (x, y, h) into screen coordinates

function perspective(x, y, h)
    -- x: field x (0 at player's side), y: field y (0=center), h: height above table
    local xm = x - BAT_MIN_X
    local ym = y - WINDOW_HEIGHT / 2
    local s = PROJ_S
    local d = PROJ_D
    local cx = PROJ_CX
    local cy = PROJ_CY
    if xm < 1 then xm = 1 end -- avoid infinity
    local screen_x = s * (ym + d / xm) + cx
    local screen_y = s * (h + d / xm) + cy
    return screen_x, screen_y
end
