-- ball.lua
local Perspective = require("perspective")

local Ball = {}
Ball.__index = Ball

-- Shape tuning in table-space (affects ellipse aspect in projection)
local KX = 1.00
local KY = 0.60

function Ball.new(x, y, dx, dy, r)
    local self = setmetatable({}, Ball)
    self.x  = x  or 320
    self.y  = y  or WINDOW_HEIGHT / 2
    self.dx = dx or 220
    self.dy = dy or 130
    self.r  = r  or 18
    -- Base is at table level; top is drawn separately at H_PUCK
    self.h  = 0
    return self
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- projective ellipse radii at (x,y,h)
local function rx_proj_at(x, y, h, r)
    local px1 = Perspective.project(x, y - r, h)
    local px2 = Perspective.project(x, y + r, h)
    return math.max(1, math.abs(px2 - px1) * 0.5) * KX
end
local function ry_proj_at(x, y, h, r)
    local _, py1 = Perspective.project(x, y, h)
    local _, py2 = Perspective.project(x, y, h + r)
    return math.max(1, math.abs(py2 - py1)) * KY
end

-- Base pass: only a soft contact shadow on the floor (no side faces)
function Ball:drawBaseShadow()
    local bx, by = Perspective.project(self.x, self.y, 0)
    local rx = rx_proj_at(self.x, self.y, 0, self.r)
    local ry = ry_proj_at(self.x, self.y, 0, self.r)
    love.graphics.setColor(0, 0, 0, 0.20)
    love.graphics.ellipse("fill", bx, by + ry*0.10, rx*1.02, ry*1.04)
end

-- Top pass: puck’s top ellipse at provided height (H_PUCK)
function Ball:drawTopAt(height, fillCol, outlineCol)
    local bx, by = Perspective.project(self.x, self.y, height)
    local rx = rx_proj_at(self.x, self.y, height, self.r)
    local ry = ry_proj_at(self.x, self.y, height, self.r)

    love.graphics.setColor((fillCol or {0.96,0.98,1.0,1.0}))
    love.graphics.ellipse("fill", bx, by, rx, ry)

    love.graphics.setColor((outlineCol or {0.08,0.10,0.12,0.95}))
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", bx, by, rx, ry)
end

return Ball






