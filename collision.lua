local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

-- Swept circle-vs-rect collision
local function swept_collision(ball, paddle)
    for i=1,8 do
        local t = i/8
        local ix = ball.prev_x + (ball.x - ball.prev_x)*t
        local iy = ball.prev_y + (ball.y - ball.prev_y)*t
        local cx = clamp(ix, paddle.x, paddle.x + paddle.width)
        local cy = clamp(iy, paddle.y, paddle.y + paddle.height)
        local dx,dy = ix - cx, iy - cy
        if dx*dx + dy*dy <= ball.radius*ball.radius then
            ball.x, ball.y = ix, iy
            return true
        end
    end
    return false
end

-- Reflect ball about normal at collision
local function bounce_normal(ball, paddle)
    local cx = clamp(ball.x, paddle.x, paddle.x + paddle.width)
    local cy = clamp(ball.y, paddle.y, paddle.y + paddle.height)
    local nx,ny = ball.x-cx, ball.y-cy
    local len = math.max(1, math.sqrt(nx*nx+ny*ny))
    nx,ny = nx/len, ny/len
    local dot = ball.dx*nx + ball.dy*ny
    ball.dx = ball.dx - 2*dot*nx
    ball.dy = ball.dy - 2*dot*ny
    ball.x = ball.x + nx*(ball.radius+0.5)
    ball.y = ball.y + ny*(ball.radius+0.5)
end

return {
    swept_collision = swept_collision,
    bounce_normal   = bounce_normal
}

   


  
  


   
   
  
   



