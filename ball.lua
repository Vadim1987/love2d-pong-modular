-- ball.lua
-- Puck with clearly visible TOP ellipse (like the screenshot).
-- Fixes: correct draw order + tiny screen-space separation when faces collapse.

local Perspective = require("perspective")

local Ball = {}
Ball.__index = Ball

-- Shape tuning
local KX = 1.00         -- horizontal ellipse scale
local KY = 0.60         -- vertical squash (lower = flatter)
local THICKNESS = 10    -- logical height (makes faces separate clearly)

-- Colors (tuned for bright top, slightly darker side)
local COL_SIDE    = {0.82, 0.86, 0.92, 1.00}
local COL_TOP     = {0.96, 0.98, 1.00, 1.00}
local COL_OUTLINE = {0.08, 0.10, 0.12, 0.95}
local COL_SHADOW  = {0.00, 0.00, 0.00, 0.30}

function Ball.new(x, y, dx, dy, r)
    local self = setmetatable({}, Ball)
    self.x = x or 320
    self.y = y or WINDOW_HEIGHT/2
    self.dx = dx or 180
    self.dy = dy or 120
    self.r  = r  or 18
    self.thickness = THICKNESS   -- logical thickness used for projection
    self.h  = 0
    return self
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Screen-space radius (both scale ~ 1/xm so shape stays stable)
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
    -- Centers of the "former bottom" (bx,by) and "former top" (tx,ty)
    local bx, by = Perspective.project(self.x, self.y, self.h)
    local tx, ty = Perspective.project(self.x, self.y, self.h + self.thickness)

    -- That very "slip" — now it's important that the NEW top (bx,by) is visible
    if math.abs(ty - by) < 1 then
        by = ty + 1
    end

    -- Radii of the ellipses at both levels
    local rx_b = (function()
        local px1 = Perspective.project(self.x, self.y - self.r, self.h)
        local px2 = Perspective.project(self.x, self.y + self.r, self.h)
        return math.max(1, math.abs(px2 - px1) * 0.5) * 1.00
    end)()
    local ry_b = (function()
        local _, py1 = Perspective.project(self.x, self.y, self.h)
        local _, py2 = Perspective.project(self.x, self.y, self.h + self.r * 0.5)
        return math.max(1, math.abs(py2 - py1)) * 0.60
    end)()

    local rx_t = (function()
        local px1 = Perspective.project(self.x, self.y - self.r, self.h + self.thickness)
        local px2 = Perspective.project(self.x, self.y + self.r, self.h + self.thickness)
        return math.max(1, math.abs(px2 - px1) * 0.5) * 1.00
    end)()
    local ry_t = (function()
        local _, py1 = Perspective.project(self.x, self.y, self.h + self.thickness)
        local _, py2 = Perspective.project(self.x, self.y, self.h + self.thickness + self.r * 0.5)
        return math.max(1, math.abs(py2 - py1)) * 0.60
    end)()

    -- Vertices of the side wall (bottom = h, top = h+thickness)
    local lbx, lby = Perspective.project(self.x, self.y - self.r, self.h)
    local rbx, rby = Perspective.project(self.x, self.y + self.r, self.h)
    local ltx, lty = Perspective.project(self.x, self.y - self.r, self.h + self.thickness)
    local rtx, rty = Perspective.project(self.x, self.y + self.r, self.h + self.thickness)

    -- 1) The shadow remains under the "physical" bottom (by)
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", bx, by + (ry_b * 0.18), rx_b * 1.08, ry_b * 1.12)

    -- 2) NEW BOTTOM: draw an ELLIPSE at (tx,ty) with the color of the "former bottom"
    love.graphics.setColor(0.90, 0.93, 0.97, 1.00)
    love.graphics.ellipse("fill", tx, ty, rx_t, ry_t)

    -- 3) Side wall — unchanged
    love.graphics.setColor(0.82, 0.86, 0.92, 1.00)
    love.graphics.polygon("fill", lbx, lby, rbx, rby, rtx, rty, ltx, lty)

    -- 4) NEW TOP: now it's the point (bx,by) — draw a light cap
    love.graphics.setColor(0.96, 0.98, 1.00, 1.00)
    love.graphics.ellipse("fill", bx, by, rx_b, ry_b)

    -- 5) Outline — also on the NEW top (bx,by)
    love.graphics.setColor(0.08, 0.10, 0.12, 0.95)
    love.graphics.ellipse("line", bx, by, rx_b, ry_b)
end


return Ball

   

  





  

