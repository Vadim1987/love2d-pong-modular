-- Paddle object with both vertical and horizontal movement

local Paddle = {}
Paddle.__index = Paddle

function Paddle:create(x, y, min_x, max_x)
    local paddle = setmetatable({}, self)
    paddle.x = x
    paddle.y = y
    paddle.width = PADDLE_WIDTH
    paddle.height = PADDLE_HEIGHT
    paddle.vspeed = 0      -- vertical speed
    paddle.hspeed = 0      -- horizontal speed
    paddle.min_x = min_x   -- horizontal limits for this bat
    paddle.max_x = max_x
    return paddle
end

-- vdir: vertical direction (-1 up, 1 down), hdir: horizontal (-1 left, 1 right)
function Paddle:update(dt, vdir, hdir)
    -- Vertical
    if vdir ~= 0 then
        self.vspeed = PADDLE_SPEED * vdir
        self.y = math.max(0, math.min(WINDOW_HEIGHT - self.height, self.y + self.vspeed * dt))
    else
        self.vspeed = 0
    end
    -- Horizontal
    if hdir ~= 0 then
        self.hspeed = PADDLE_HSPEED * hdir
        self.x = math.max(self.min_x, math.min(self.max_x, self.x + self.hspeed * dt))
    else
        self.hspeed = 0
    end
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle

      
       

