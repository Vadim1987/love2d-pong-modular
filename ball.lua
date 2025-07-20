-- Ball module

local Ball = {}
Ball.__index = Ball

function Ball:create()
    local ball = setmetatable({}, self)
    ball.x = WINDOW_WIDTH / 2 - BALL_SIZE / 2
    ball.y = WINDOW_HEIGHT / 2 - BALL_SIZE / 2
    ball.dx = math.random(2) == 1 and BALL_SPEED_X or -BALL_SPEED_X
    ball.dy = (math.random() - 0.5) * 2 * BALL_SPEED_Y
    ball.size = BALL_SIZE
    return ball
end

function Ball:reset()
    self.x = WINDOW_WIDTH / 2 - BALL_SIZE / 2
    self.y = WINDOW_HEIGHT / 2 - BALL_SIZE / 2
    self.dx = math.random(2) == 1 and BALL_SPEED_X or -BALL_SPEED_X
    self.dy = (math.random() - 0.5) * 2 * BALL_SPEED_Y
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:draw()
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

return Ball
