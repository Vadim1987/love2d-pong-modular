local Paddle = {}
Paddle.__index = Paddle

function Paddle:create(x, y, isPlayer, isOpponent)
    local paddle = setmetatable({}, self)
    paddle.x = x
    paddle.y = y
    paddle.width = PADDLE_WIDTH
    paddle.height = PADDLE_HEIGHT
    paddle.vspeed = 0
    paddle.hspeed = 0
    paddle.isPlayer = isPlayer or false
    paddle.isOpponent = isOpponent or false
    return paddle
end

function Paddle:update(dt, vdir, hdir)
    -- Vertical
    if vdir ~= 0 then
        self.vspeed = PADDLE_SPEED * vdir
        self.y = math.max(0, math.min(WINDOW_HEIGHT - self.height, self.y + self.vspeed * dt))
    else
        self.vspeed = 0
    end
    -- Horizontal (до центра поля)
    if hdir ~= 0 then
        local minX, maxX
        if self.isPlayer then
            minX = 0
            maxX = BAT_MAX_X
        elseif self.isOpponent then
            minX = BAT_MIN_X_OPP
            maxX = WINDOW_WIDTH - PADDLE_WIDTH
        end
        self.hspeed = PADDLE_HSPEED * hdir
        self.x = math.max(minX, math.min(maxX, self.x + self.hspeed * dt))
    else
        self.hspeed = 0
    end
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle

