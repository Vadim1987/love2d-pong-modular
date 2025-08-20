-- ball.lua
-- Puck (ball) rendering for the Shufflepuck-style perspective table.
-- Iteration 3 compatible:
--   - Iteration 1: bottom ellipse on the table (white)
--   - Iteration 3: vertical wall from bottom center to top center
--   - Iteration 2: top ellipse at height H_PUCK (colored)
--
-- Public API used by main.lua:
--   Ball.new(x, y, dx, dy, r)
--   :update(dt)
--   :drawBottomEllipse()         -- draw white bottom on h=0
--   :drawBaseShadow()            -- optional soft shadow on h=0
--   :drawWallToTop(hTop, ...)    -- draw vertical wall (rect) up to hTop
--   :drawTopAt(hTop, ...)        -- draw colored top ellipse at hTop
--
-- Notes:
-- - The perspective projection is handled by Perspective.project(x, y, h).
-- - Ellipses are sized by projecting table-space offsets to screen-space,
--   so their radii change correctly with depth (x).

local Perspective = require("perspective")

local Ball = {}
Ball.__index = Ball

-----------------------------------------------------------------------
-- Shape tuning in table-space (affects ellipse aspect after projection)
-- KX, KY are correction multipliers to make the projected ellipse
-- look “right” for the current Perspective.project().
-----------------------------------------------------------------------
local KX = 1.00
local KY = 0.60

-----------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------
function Ball.new(x, y, dx, dy, r)
    local self = setmetatable({}, Ball)
    self.x  = x  or 320
    self.y  = y  or WINDOW_HEIGHT / 2
    self.dx = dx or 220
    self.dy = dy or 130
    self.r  = r  or 18
    -- Table plane height for bottom ellipse/shadow
    self.h  = 0
    return self
end

-----------------------------------------------------------------------
-- Update position in table-space (x along depth, y across the table)
-----------------------------------------------------------------------
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-----------------------------------------------------------------------
-- Helpers: compute projected radii of the puck’s ellipse
-- rx_proj_at: horizontal screen radius by projecting (y +/- r)
-- ry_proj_at: vertical screen radius by projecting (h .. h + r)
-----------------------------------------------------------------------
local function rx_proj_at(x, y, h, r)
    local px1 = Perspective.project(x, y - r, h)   -- returns px (screen X)
    local px2 = Perspective.project(x, y + r, h)
    -- Half of the distance in screen X, scaled
    return math.max(1, math.abs(px2 - px1) * 0.5) * KX
end

local function ry_proj_at(x, y, h, r)
    local _, py1 = Perspective.project(x, y, h)     -- returns py (screen Y)
    local _, py2 = Perspective.project(x, y, h + r)
    -- Full vertical distance in screen Y, scaled
    return math.max(1, math.abs(py2 - py1)) * KY
end

-----------------------------------------------------------------------
-- Iteration 1: bottom ellipse (white) on the table plane (h = 0)
-- Drawn before any vertical surfaces or colored tops.
-----------------------------------------------------------------------
function Ball:drawBottomEllipse()
    local bx, by = Perspective.project(self.x, self.y, 0)
    local rx = rx_proj_at(self.x, self.y, 0, self.r)
    local ry = ry_proj_at(self.x, self.y, 0, self.r)

    -- fill
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.ellipse("fill", bx, by, rx, ry)

    -- outline
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", bx, by, rx, ry)
end

-----------------------------------------------------------------------
-- Optional: subtle contact shadow on the floor (h = 0).
-- This helps keep contours readable on the checkered grid.
-----------------------------------------------------------------------
function Ball:drawBaseShadow()
    local bx, by = Perspective.project(self.x, self.y, 0)
    local rx = rx_proj_at(self.x, self.y, 0, self.r)
    local ry = ry_proj_at(self.x, self.y, 0, self.r)
    love.graphics.setColor(0, 0, 0, 0.20)
    -- Slight offset in Y to suggest contact with the floor
    love.graphics.ellipse("fill", bx, by + ry * 0.10, rx * 1.02, ry * 1.04)
end

-----------------------------------------------------------------------
-- Iteration 3: vertical wall (rectangle) from bottom center (h=0)
-- to top center (h=hTop). The wall uses the same color family as the
-- top ellipse. Width equals the diameter of the *bottom* ellipse in
-- screen-space for stability (projection changes with height).
--
-- Draw order (as per spec):
--   bottom ellipse -> wall -> (conditionally) bat sides -> top ellipse
-----------------------------------------------------------------------
function Ball:drawWallToTop(hTop, fillCol, outlineCol)
    local bx0, by0 = Perspective.project(self.x, self.y, 0)     -- bottom center
    local bxT, byT = Perspective.project(self.x, self.y, hTop)  -- top center
    local rx0      = rx_proj_at(self.x, self.y, 0, self.r)      -- bottom half-width

    local x1 = bx0 - rx0
    local y1 = math.min(by0, byT)
    local w  = rx0 * 2
    local h  = math.abs(byT - by0)

    -- fill
    love.graphics.setColor(fillCol or COLOR_PUCK_TOP_FILL)
    love.graphics.rectangle("fill", x1, y1, w, h)

    -- outline
    love.graphics.setColor(outlineCol or COLOR_PUCK_TOP_OUTLINE)
    love.graphics.setLineWidth(1.4)
    love.graphics.rectangle("line", x1, y1, w, h)
end

-----------------------------------------------------------------------
-- Iteration 2: top ellipse at height hTop (colored).
-- This is drawn after the vertical wall (and after some bat sides
-- depending on per-side depth rules handled in main.lua).
-----------------------------------------------------------------------
function Ball:drawTopAt(hTop, fillCol, outlineCol)
    local bx, by = Perspective.project(self.x, self.y, hTop)
    local rx = rx_proj_at(self.x, self.y, hTop, self.r)
    local ry = ry_proj_at(self.x, self.y, hTop, self.r)

    -- fill
    love.graphics.setColor(fillCol or COLOR_PUCK_TOP_FILL)
    love.graphics.ellipse("fill", bx, by, rx, ry)

    -- outline
    love.graphics.setColor(outlineCol or COLOR_PUCK_TOP_OUTLINE)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", bx, by, rx, ry)
end

return Ball









