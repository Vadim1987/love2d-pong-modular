-- paddle.lua
local Perspective = require("perspective")

local Paddle = {}
Paddle.__index = Paddle

-- widthY — width along table Y; depthX — length along table X (into depth)
function Paddle.new(x, y, widthY, depthX)
    local self = setmetatable({}, Paddle)
    self.x = x or 160
    self.y = y or WINDOW_HEIGHT / 2
    self.w = (widthY or 52) * 2   -- full size along Y (table space)
    self.d = depthX or 36         -- length along X (depth)
    self.moveSpeed = 320
    return self
end

function Paddle:update(dt, inputY)
    if inputY then self.y = self.y + inputY * self.moveSpeed * dt end
end

-- ===== Base pass on the table (iteration 1 look) =====
local COL_FILL_BASE    = {0.96, 0.98, 1.00, 1.0}
local COL_OUTLINE_BASE = {0.00, 0.00, 0.00, 1.0}
local COL_SHADOW       = {0.00, 0.00, 0.00, 0.25}

-- floor shadow sizes
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

function Paddle:drawBasePerspective()
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    -- soft floor shadow
    do
        local bx, by = Perspective.project(self.x, self.y, 0)
        local rx = rx_proj_at(self.x, self.y, 0, halfY)
        local ry = ry_proj_at(self.x, self.y, 0, self.d * 0.5)
        love.graphics.setColor(COL_SHADOW)
        love.graphics.ellipse("fill", bx, by + ry*0.12, rx*1.02, ry*1.06)
    end

    -- rectangle footprint at h=0 (projects as trapezoid)
    local nLx, nLy = Perspective.project(xN, self.y - halfY, 0)
    local nRx, nRy = Perspective.project(xN, self.y + halfY, 0)
    local fRx, fRy = Perspective.project(xF, self.y + halfY, 0)
    local fLx, fLy = Perspective.project(xF, self.y - halfY, 0)

    love.graphics.setColor(COL_FILL_BASE)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)

    love.graphics.setColor(COL_OUTLINE_BASE)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

-- ===== Iteration 3: vertical sides selection =====
-- Returns a list of side descriptors to potentially draw:
-- { id="near"/"left"/"right", depthX = <characteristic x for ordering> }
function Paddle:visibleSides()
    local sides = {}
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    -- Rule: only the NEAR (xN) side is visible, FAR is not.
    table.insert(sides, { id = "near", depthX = xN })

    -- Rule: of LEFT/RIGHT at most one is visible.
    -- Left side is visible only if it projects to the RIGHT of screen center.
    -- Right side is visible only if it projects to the LEFT of center.
    local cx = Perspective.center_x()

    -- project midpoints of edges at mid-height (h = H_BAT * 0.5) for robust test
    local function edge_mid_px(yEdge)
        local px, _ = Perspective.project((xN + xF) * 0.5, yEdge, H_BAT * 0.5)
        return px
    end

    local yL = self.y - halfY
    local yR = self.y + halfY
    local pxL = edge_mid_px(yL)
    local pxR = edge_mid_px(yR)

    if pxL > cx then
        table.insert(sides, { id = "left",  depthX = xN })
    elseif pxR < cx then
        table.insert(sides, { id = "right", depthX = xN })
    end

    return sides
end

-- Draw one vertical side as a quad between h=0 and hTop.
-- id: "near" | "left" | "right"
function Paddle:drawSide(id, hTop, fillCol, outlineCol)
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    local p = {}

    if id == "near" then
        -- near side at x = xN, spanning y in [y - halfY, y + halfY]
        local y1, y2 = self.y - halfY, self.y + halfY
        p[1], p[2] = Perspective.project(xN, y1, 0)
        p[3], p[4] = Perspective.project(xN, y2, 0)
        p[5], p[6] = Perspective.project(xN, y2, hTop)
        p[7], p[8] = Perspective.project(xN, y1, hTop)

    elseif id == "left" then
        -- left side at y = y - halfY, spanning x in [xN, xF]
        local yL = self.y - halfY
        p[1], p[2] = Perspective.project(xN, yL, 0)
        p[3], p[4] = Perspective.project(xF, yL, 0)
        p[5], p[6] = Perspective.project(xF, yL, hTop)
        p[7], p[8] = Perspective.project(xN, yL, hTop)

    elseif id == "right" then
        -- right side at y = y + halfY, spanning x in [xN, xF]
        local yR = self.y + halfY
        p[1], p[2] = Perspective.project(xN, yR, 0)
        p[3], p[4] = Perspective.project(xF, yR, 0)
        p[5], p[6] = Perspective.project(xF, yR, hTop)
        p[7], p[8] = Perspective.project(xN, yR, hTop)
    else
        return
    end

    love.graphics.setColor(fillCol or COLOR_BAT_SIDE_FILL)
    love.graphics.polygon("fill", p)

    love.graphics.setColor(outlineCol or COLOR_BAT_SIDE_OUTLINE)
    love.graphics.setLineWidth(1.6)
    love.graphics.polygon("line", p)
end

-- Tops (iteration 2) remain as before: footprint at height hTop
function Paddle:drawTopOnly(hTop, fillCol, outlineCol)
    local halfY = self.w * 0.5
    local xN = self.x
    local xF = self.x + self.d

    local nLx, nLy = Perspective.project(xN, self.y - halfY, hTop)
    local nRx, nRy = Perspective.project(xN, self.y + halfY, hTop)
    local fRx, fRy = Perspective.project(xF, self.y + halfY, hTop)
    local fLx, fLy = Perspective.project(xF, self.y - halfY, hTop)

    love.graphics.setColor(fillCol or COLOR_BAT_TOP_FILL)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)

    love.graphics.setColor(outlineCol or COLOR_BAT_TOP_OUTLINE)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

-- Back-compat
function Paddle:drawPerspective()
    self:drawBasePerspective()
end

return Paddle






    
