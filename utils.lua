-- project_to_screen: f(x,y) = s*(ym + d/xm, h + d/xm) + c
function project_to_screen(x, y, h)
    local xm = x - ORIGIN_X
    if xm < 1 then xm = 1 end
    local ym = y - FIELD_CENTER_Y
    local s  = PROJ_SCALE
    local d  = PROJ_DIST
    local sx = s * (ym + d / xm) + PROJ_CX
    local sy = s * (h  + d / xm) + PROJ_CY
    return sx, sy
end

-- Draw a “3D slab” for paddle: top at height top_h, bottom at bottom_h
function draw_perspective_rect(x1, y1, x2, y2, top_h, bottom_h)
    local p1x,p1y = project_to_screen(x1, y1, top_h)
    local p2x,p2y = project_to_screen(x2, y1, top_h)
    local p3x,p3y = project_to_screen(x2, y2, bottom_h)
    local p4x,p4y = project_to_screen(x1, y2, bottom_h)
    love.graphics.polygon("fill", p1x,p1y, p2x,p2y, p3x,p3y, p4x,p4y)
end

