-- paddle.lua
local Perspective = require("perspective")

local Paddle = {}
Paddle.__index = Paddle

-- widthY — width along table Y; depthX — length along table X (into the screen)
function Paddle.new(x, y, widthY, depthX)
    local self = setmetatable({}, Paddle)
    self.x = x or 160
    self.y = y or WINDOW_HEIGHT / 2
    self.w = (widthY or 52) * 2   -- full size along Y on the table
    self.d = depthX or 36         -- length into depth along X
    self.moveSpeed = 320
    return self
end

function Paddle:update(dt, inputY)
    if inputY then self.y = self.y + inputY * self.moveSpeed * dt end
end

-- Base B/W styling (iteration 1 look)
local COL_FILL_BASE    = {0.96, 0.98, 1.00, 1.0}
local COL_OUTLINE_BASE = {0.00, 0.00, 0.00, 1.0}
local COL_SHADOW       = {0.00, 0.00, 0.00, 0.25}

-- quick projected radii for a floor shadow
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

-- Base pass on the table (h=0): flat trapezoid (rectangle in world-space)
function Paddle:drawBasePerspective()
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    -- floor shadow for readability
    do
        local bx, by = Perspective.project(self.x, self.y, 0)
        local rx = rx_proj_at(self.x, self.y, 0, halfY)
        local ry = ry_proj_at(self.x, self.y, 0, self.d * 0.5)
        love.graphics.setColor(COL_SHADOW)
        love.graphics.ellipse("fill", bx, by + ry*0.12, rx*1.02, ry*1.06)
    end

    -- 4 corners on the table (h = 0)
    local nLx, nLy = Perspective.project(xN, self.y - halfY, 0)
    local nRx, nRy = Perspective.project(xN, self.y + halfY, 0)
    local fRx, fRy = Perspective.project(xF, self.y + halfY, 0)
    local fLx, fLy = Perspective.project(xF, self.y - halfY, 0)

    -- fill & outline (base B/W)
    love.graphics.setColor(COL_FILL_BASE)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)

    love.graphics.setColor(COL_OUTLINE_BASE)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

-- Top pass only (no sides): same footprint but at height `height`
function Paddle:drawTopOnly(height, fillCol, outlineCol)
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    local nLx, nLy = Perspective.project(xN, self.y - halfY, height)
    local nRx, nRy = Perspective.project(xN, self.y + halfY, height)
    local fRx, fRy = Perspective.project(xF, self.y + halfY, height)
    local fLx, fLy = Perspective.project(xF, self.y - halfY, height)

    love.graphics.setColor(fillCol or {1,1,1,1})
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)

    love.graphics.setColor(outlineCol or {0,0,0,1})
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

-- Back-compat if someone still calls :drawPerspective()
function Paddle:drawPerspective()
    self:drawBasePerspective()
end

return Paddle



  


    
