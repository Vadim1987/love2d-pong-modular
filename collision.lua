-- Collision and bounce logic

local function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.size and
           a.y < b.y + b.height and
           b.y < a.y + a.size
end

local function bounceSimple(ball, paddle)
    -- Simple: just flip horizontal speed
    ball.dx = -ball.dx
end

local function bounceAddPaddleVelocity(ball, paddle)
    -- Add a portion of the paddle's speed to ball's vertical speed
    ball.dx = -ball.dx
    ball.dy = ball.dy + 0.35 * paddle.speed
end

return {
    checkCollision = checkCollision,
    bounceSimple = bounceSimple,
    bounceAddPaddleVelocity = bounceAddPaddleVelocity
}
