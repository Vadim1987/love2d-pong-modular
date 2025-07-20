-- Player paddle model (no opponent in this iteration)

local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(x, y)
    local o = setmetatable({}, self)
    o.x = x
    o.y = y
    o.width  = PADDLE_WIDTH
    o.height = PADDLE_HEIGHT
    return o
end

-- vdir: movement along depth axis (X), hdir: along lateral axis (Y)
-- Directions: vdir = -1 moves towards player (smaller x), +1 moves deeper (bigger x)
function Paddle:update(dt, vdir, hdir)
    if vdir ~= 0 then
        self.x = self.x + vdir * PADDLE_SPEED * dt
    end
    if hdir ~= 0 then
        self.y = self.y + hdir * PADDLE_SPEED * dt
    end
    -- Clamp to allowed zone
    self.x = math.max(ZONE_MIN_X, math.min(ZONE_MAX_X, self.x))
    self.y = math.max(ZONE_MIN_Y, math.min(ZONE_MAX_Y, self.y))
end

return Paddle

