-- paddle.lua
local Perspective = require("perspective")

local Paddle = {}
Paddle.__index = Paddle

-- widthY — width по оси Y (на столе), depthX — width по оси X (в глубину)
function Paddle.new(x, y, widthY, depthX)
    local self = setmetatable({}, Paddle)
    self.x = x or 160
    self.y = y or WINDOW_HEIGHT / 2
    self.w = (widthY or 52) * 2   
    self.d = depthX or 36         
    self.moveSpeed = 320
    return self
end

function Paddle:update(dt, inputY)
    if inputY then
        self.y = self.y + inputY * self.moveSpeed * dt
    end
end

-- Colors (B/W minimalism)
local COL_FILL    = {0.96, 0.98, 1.00, 1.0}
local COL_OUTLINE = {0.00, 0.00, 0.00, 1.0}
local COL_SHADOW  = {0.00, 0.00, 0.00, 0.25}

-- quick "radius" estimate for shadow ellipse on table
local function rx_proj_at(x, y, h, r)
    local px1 = Perspective.project(x, y - r, h)
    local px2 = Perspective.project(x, y + r, h)
    return math.max(1, math.abs(px2 - px1) * 0.5)
end
local function ry_proj_at(x, y, h, r)
    local _, py1 = Perspective.project(x, y, h)
    local _, py2 = Perspective.project(x, y, h + r)
    return math.max(1, math.abs(py2 - py1))
end

-- Flat trapezoid: rectangle in the world (x..x+d, y±w/2) => looks like a trapezoid on the screen
function Paddle:drawPerspective()
    local halfY = self.w * 0.5
    local xN = self.x            -- (near)
    local xF = self.x + self.d   -- (far)

    -- shadow (barely noticeable), at floor level h=0
    do
        local bx, by = Perspective.project(self.x, self.y, 0)
        local rx = rx_proj_at(self.x, self.y, 0, halfY)
        local ry = ry_proj_at(self.x, self.y, 0, self.d * 0.5)
        love.graphics.setColor(COL_SHADOW)
        love.graphics.ellipse("fill", bx, by + ry*0.12, rx*1.02, ry*1.06)
    end

    -- 4 angles in the plane of the table (h=0)
    local nLx, nLy = Perspective.project(xN, self.y - halfY, 0)
    local nRx, nRy = Perspective.project(xN, self.y + halfY, 0)
    local fRx, fRy = Perspective.project(xF, self.y + halfY, 0)
    local fLx, fLy = Perspective.project(xF, self.y - halfY, 0)

    -- filling
    love.graphics.setColor(COL_FILL)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)

    -- outline (sharp, no gradients)
    love.graphics.setColor(COL_OUTLINE)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

return Paddle

   

  


    
