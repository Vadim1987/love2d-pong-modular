-- Ball / puck with previous position for swept collision

local Ball = {}
Ball.__index = Ball

function Ball:new()
    local o = setmetatable({}, self)
    o.radius = BALL_RADIUS
    o.x = (ZONE_MIN_X + ZONE_MAX_X) / 2
    o.y = (ZONE_MIN_Y + ZONE_MAX_Y) / 2
    o.dx = BALL_SPEED_X * (love.math.random(2) == 1 and 1 or -1)
    o.dy = BALL_SPEED_Y * (love.math.random(2) == 1 and 1 or -1)
    o.prev_x = o.x
    o.prev_y = o.y
    return o
end

function Ball:reset()
    self.x = (ZONE_MIN_X + ZONE_MAX_X) / 2
    self.y = (ZONE_MIN_Y + ZONE_MAX_Y) / 2
    self.dx = BALL_SPEED_X * (love.math.random(2) == 1 and 1 or -1)
    self.dy = BALL_SPEED_Y * (love.math.random(2) == 1 and 1 or -1)
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

  


  





  

