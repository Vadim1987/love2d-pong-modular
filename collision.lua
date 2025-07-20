-- Circle vs rectangle collision + tangent bounce (mirrors velocity vector about normal)
local function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Basic circle-rectangle collision at current sample (no swept)
local function checkCircleRect(ball, paddle)
    -- Find closest point on paddle to ball center
    local closestX = clamp(ball.x, paddle.x, paddle.x + paddle.width)
    local closestY = clamp(ball.y, paddle.y, paddle.y + paddle.height)
    local dx = ball.x - closestX
    local dy = ball.y - closestY
    return (dx*dx + dy*dy) <= (ball.radius * ball.radius)
end

-- Swept collision: check if ball's movement segment crossed paddle during dt
local function sweptCircleRect(ball, paddle)
    -- For basic implementation, check N points between prev and current position
    local steps = 8
    for i=1,steps do
        local t = i / steps
        local test_x = ball.prev_x + (ball.x - ball.prev_x) * t
        local test_y = ball.prev_y + (ball.y - ball.prev_y) * t
        local closestX = clamp(test_x, paddle.x, paddle.x + paddle.width)
        local closestY = clamp(test_y, paddle.y, paddle.y + paddle.height)
        local dx = test_x - closestX
        local dy = test_y - closestY
        if (dx*dx + dy*dy) <= (ball.radius * ball.radius) then
            -- Set the ball's position to the contact point!
            ball.x, ball.y = test_x, test_y
            return true
        end
    end
    return false
end

-- Tangent (normal) bounce: reflect velocity about the normal at collision point
local function bounceTangent(ball, paddle)
    -- Find collision normal at point of contact
    local closestX = clamp(ball.x, paddle.x, paddle.x + paddle.width)
    local closestY = clamp(ball.y, paddle.y, paddle.y + paddle.height)
    local nx = ball.x - closestX
    local ny = ball.y - closestY
    local len = math.sqrt(nx * nx + ny * ny)
    if len == 0 then
        nx, ny = 1, 0 -- fallback: horizontal
    else
        nx, ny = nx / len, ny / len
    end
    -- Reflect velocity
    local vDotN = ball.dx * nx + ball.dy * ny
    ball.dx = ball.dx - 2 * vDotN * nx
    ball.dy = ball.dy - 2 * vDotN * ny
end

return {
    checkCollision = checkCircleRect,
    sweptCollision = sweptCircleRect,
    bounceTangent = bounceTangent
}


