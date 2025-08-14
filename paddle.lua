-- paddle.lua
local Perspective = require("perspective")

local Paddle = {}
Paddle.__index = Paddle

function Paddle.new(x, y, widthY, heightH)
    local self = setmetatable({}, Paddle)
    self.x = x or 160
    self.y = y or WINDOW_HEIGHT / 2
    self.w = (widthY or 52) * 2
    self.h = heightH or 68
    self.moveSpeed = 320
    return self
end

function Paddle:update(dt, inputY)
    if inputY then
        self.y = self.y + inputY * self.moveSpeed * dt
    end
end

-- colors
local COL_SHADOW   = {0, 0, 0, 0.32}
local COL_SIDE_L   = {0.62, 0.72, 0.82, 1.0}
local COL_SIDE_R   = {0.82, 0.90, 0.98, 1.0}
local COL_RIM      = {0.68, 0.86, 0.96, 1.0}  
local COL_TOP      = {0.96, 0.98, 1.00, 1.0}
local COL_OUTLINE  = {0, 0, 0, 1.0}           

-- additional projection function
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

function Paddle:drawPerspective()
    local halfY = self.w * 0.5

    local lbx, lby = Perspective.project(self.x, self.y - halfY, 0)
    local rbx, rby = Perspective.project(self.x, self.y + halfY, 0)
    local ltx, lty = Perspective.project(self.x, self.y - halfY, self.h)
    local rtx, rty = Perspective.project(self.x, self.y + halfY, self.h)

    local bx, by = Perspective.project(self.x, self.y, 0)

    -- shadow
    local rx = rx_proj_at(self.x, self.y, 0, halfY)
    local ry = ry_proj_at(self.x, self.y, 0, self.h * 0.5)
    love.graphics.setColor(COL_SHADOW)
    love.graphics.ellipse("fill", bx, by + ry*0.18, rx*1.10, ry*1.18)

    -- side walls
    local tx, ty = Perspective.project(self.x, self.y, self.h)
    love.graphics.setColor(COL_SIDE_L)
    love.graphics.polygon("fill", lbx, lby, ltx, lty, tx, ty, bx, by)
    love.graphics.setColor(COL_SIDE_R)
    love.graphics.polygon("fill", bx, by, tx, ty, rtx, rty, rbx, rby)

    -- inner panel
    local insetY = math.max(3, self.w * 0.08)
    local insetH = math.max(3, self.h * 0.18)
    local halfY_in = math.max(1, halfY - insetY)
    local h_in     = math.max(0, self.h - insetH)

    local ilbx, ilby = Perspective.project(self.x, self.y - halfY_in, 0)
    local irbx, irby = Perspective.project(self.x, self.y + halfY_in, 0)
    local iltx, ilty = Perspective.project(self.x, self.y - halfY_in, h_in)
    local irtx, irty = Perspective.project(self.x, self.y + halfY_in, h_in)

    love.graphics.setColor(COL_TOP)
    love.graphics.polygon("fill", iltx, ilty, irtx, irty, irbx, irby, ilbx, ilby)

    -- blue thick rim
    love.graphics.setColor(COL_RIM)
    love.graphics.setLineWidth(6)
    love.graphics.setLineJoin("miter")
    love.graphics.polygon("line", ltx, lty, rtx, rty, rbx, rby, lbx, lby)

    -- black thin outline on top
    love.graphics.setColor(COL_OUTLINE)
    love.graphics.setLineWidth(1.6)
    love.graphics.polygon("line", ltx, lty, rtx, rty, rbx, rby, lbx, lby)
    love.graphics.polygon("line", iltx, ilty, irtx, irty, irbx, irby, ilbx, ilby)
end

return Paddle


    
