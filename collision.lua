-- Swept circle vs axis-aligned rectangle (paddle) in 2D field space
-- + clean reflection about collision normal

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function swept_paddle_collision(ball, paddle)
    local steps = 8
    for i = 1, steps do
        local t = i / steps
        local ix = ball.prev_x + (ball.x - ball.prev_x) * t
        local iy = ball.prev_y + (ball.y - ball.prev_y) * t
        local cx = clamp(ix, paddle.x, paddle.x + paddle.width)
        local cy = clamp(iy, paddle.y, paddle.y + paddle.height)
        local dx = ix - cx
        local dy = iy - cy
        if dx * dx + dy * dy <= ball.radius * ball.radius then
            -- lock ball at impact point
            ball.x, ball.y = ix, iy
            return true
        end
    end
    return false
end

local function bounce_normal(ball, paddle)
    local cx = clamp(ball.x, paddle.x, paddle.x + paddle.width)
    local cy = clamp(ball.y, paddle.y, paddle.y + paddle.height)
    local nx = ball.x - cx
    local ny = ball.y - cy
    local len = math.sqrt(nx * nx + ny * ny)
    if len == 0 then
        nx, ny = 1, 0
        len = 1
    end
    nx, ny = nx / len, ny / len
    local vdot = ball.dx * nx + ball.dy * ny
    ball.dx = ball.dx - 2 * vdot * nx
    ball.dy = ball.dy - 2 * vdot * ny
    -- Nudge out to avoid re-collision
    ball.x = ball.x + nx * (ball.radius + 0.5)
    ball.y = ball.y + ny * (ball.radius + 0.5)
end

return {
    swept_collision = swept_paddle_collision,
    bounce_normal   = bounce_normal
}

   


  
  


   
   
  
   



