-- Ball module: now circular and with previous position tracking

local Ball = {}
Ball.__index = Ball

function Ball:create()
    local ball = setmetatable({}, self)
    ball.radius = BALL_SIZE         -- Now "BALL_SIZE" is radius!
    ball.x = WINDOW_WIDTH / 2
    ball.y = WINDOW_HEIGHT / 2
    ball.dx = math.random(2) == 1 and BALL_SPEED_X or -BALL_SPEED_X
    ball.dy = (math.random() - 0.5) * 2 * BALL_SPEED_Y
    ball.prev_x = ball.x
    ball.prev_y = ball.y
    return ball
end

function Ball:reset()
    self.x = WINDOW_WIDTH / 2
    self.y = WINDOW_HEIGHT / 2
    self.dx = math.random(2) == 1 and BALL_SPEED_X or -BALL_SPEED_X
    self.dy = (math.random() - 0.5) * 2 * BALL_SPEED_Y
    self.prev_x = self.x
    self.prev_y = self.y
end

function Ball:update(dt)
    self.prev_x = self.x
    self.prev_y = self.y
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:draw()
    love.graphics.circle('fill', self.x, self.y, self.radius)
end

return Ball
