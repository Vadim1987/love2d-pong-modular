local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(x, y)
    return setmetatable({
        x = x,
        y = y,
        width  = PADDLE_WIDTH,
        height = PADDLE_HEIGHT
    }, Paddle)
end

-- vdir: -1..1 along depth (x), hdir: -1..1 along lateral (y)
function Paddle:update(dt, vdir, hdir)
    self.x = math.max(ZONE_MIN_X, math.min(ZONE_MAX_X, self.x + vdir * PADDLE_SPEED * dt))
    self.y = math.max(ZONE_MIN_Y, math.min(ZONE_MAX_Y, self.y + hdir * PADDLE_SPEED * dt))
end

return Paddle

    
