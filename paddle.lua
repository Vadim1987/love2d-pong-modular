-- Paddle module

local Paddle = {}
Paddle.__index = Paddle

function Paddle:create(x, y, isPlayer)
    local paddle = setmetatable({}, self)
    paddle.x = x
    paddle.y = y
    paddle.width = PADDLE_WIDTH
    paddle.height = PADDLE_HEIGHT
    paddle.speed = 0
    paddle.isPlayer = isPlayer or false
    return paddle
end

function Paddle:update(dt, direction)
    if direction ~= 0 then
        self.speed = PADDLE_SPEED * direction
        self.y = math.max(0, math.min(WINDOW_HEIGHT - self.height, self.y + self.speed * dt))
    else
        self.speed = 0
    end
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle
