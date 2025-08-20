-- ball.lua
local Perspective = require("perspective")

local Ball = {}
Ball.__index = Ball

-- Form settings (horiz/vert "radii" in table coordinates)
local KX = 1.00
local KY = 0.60

function Ball.new(x, y, dx, dy, r)
    local self = setmetatable({}, Ball)
    self.x = x or 320
    self.y = y or WINDOW_HEIGHT/2
    self.dx = dx or 220
    self.dy = dy or 130
    self.r  = r  or 18
    self.h  = 0           -- EVERYTHING is in the plane of the table
    return self
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

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

function Ball:drawPerspective()
    local bx, by = Perspective.project(self.x, self.y, self.h)
    local rx = rx_proj_at(self.x, self.y, self.h, self.r)
    local ry = ry_proj_at(self.x, self.y, self.h, self.r)

    -- light "contact" shadow so the outline doesn't get lost on the tile
    love.graphics.setColor(0, 0, 0, 0.20)
    love.graphics.ellipse("fill", bx, by + ry*0.10, rx*1.02, ry*1.04)

    -- puck ellipse (fill + outline)
    love.graphics.setColor(0.96, 0.98, 1.00, 1.0)
    love.graphics.ellipse("fill", bx, by, rx, ry)
    love.graphics.setColor(0.08, 0.10, 0.12, 0.95)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", bx, by, rx, ry)
end

return Ball



