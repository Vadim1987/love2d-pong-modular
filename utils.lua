-- Perspective projection:
-- f(x, y) = s * (ym + d / xm, h + d / xm) + c
-- xm = x - ORIGIN_X  (depth offset so player is at xm = 0)
-- ym = y - FIELD_CENTER_Y (centered laterally)
-- h = object height above eye level (a stylistic offset)
-- NOTE: We clamp xm to >= 1 to avoid division blow-up near the eye plane.

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

-- Helper: draw a filled quad defined by two world corners (x1,y1) top-left
-- and (x2,y2) bottom-right, projected with top height & bottom height.
-- We approximate “3D slab” of the paddle by projecting top edge with BAT_HEIGHT_3D
-- and bottom edge with 0 height.
function draw_perspective_rect(x1, y1, x2, y2, top_h, bottom_h)
    local p1x, p1y = project_to_screen(x1, y1, top_h)
    local p2x, p2y = project_to_screen(x2, y1, top_h)
    local p3x, p3y = project_to_screen(x2, y2, bottom_h)
    local p4x, p4y = project_to_screen(x1, y2, bottom_h)
    love.graphics.polygon("fill", p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
end


