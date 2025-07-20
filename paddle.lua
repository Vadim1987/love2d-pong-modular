local Paddle = {}
Paddle.__index = Paddle

function Paddle:create(x, y)
    local paddle = setmetatable({}, self)
    paddle.x = x
    paddle.y = y
    paddle.width = PADDLE_WIDTH
    paddle.height = PADDLE_HEIGHT
    return paddle
end

function Paddle:update(dt, vdir, hdir)
    if vdir ~= 0 then
        self.x = math.max(BAT_MIN_X, math.min(BAT_MAX_X, self.x + vdir * PADDLE_SPEED * dt))
    end
    if hdir ~= 0 then
        self.y = math.max(BAT_MIN_Y, math.min(BAT_MAX_Y, self.y + hdir * PADDLE_SPEED * dt))
    end
end

return Paddle

