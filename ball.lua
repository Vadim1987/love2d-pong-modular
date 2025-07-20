local Ball = {}
Ball.__index = Ball

function Ball:create()
    local ball = setmetatable({}, self)
    ball.radius = BALL_SIZE
    ball.x = (BAT_MIN_X + BAT_MAX_X) / 2
    ball.y = (BAT_MIN_Y + BAT_MAX_Y) / 2
    ball.dx = BALL_SPEED_X * (math.random(2) == 1 and 1 or -1)
    ball.dy = BALL_SPEED_Y * (math.random(2) == 1 and 1 or -1)
    ball.prev_x = ball.x
    ball.prev_y = ball.y
    return ball
end

function Ball:reset()
    self.x = (BAT_MIN_X + BAT_MAX_X) / 2
    self.y = (BAT_MIN_Y + BAT_MAX_Y) / 2
    self.dx = BALL_SPEED_X * (math.random(2) == 1 and 1 or -1)
    self.dy = BALL_SPEED_Y * (math.random(2) == 1 and 1 or -1)
    self.prev_x = self.x
    self.prev_y = self.y
end

function Ball:update(dt)
    self.prev_x = self.x
    self.prev_y = self.y
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

return Ball

  





  

