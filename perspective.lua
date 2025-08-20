-- perspective.lua
-- Pseudo-3D projection for first-person Shufflepuck-style view

local Perspective = {}

-- Camera & table parameters
local ORIGIN_X       = 0                   -- camera position on X axis (before player's edge)
local FIELD_CENTER_Y = WINDOW_HEIGHT / 2   -- center of table on Y axis
local S              = 200                 -- base scale factor
local D              = 300                 -- projection plane distance
local EPS            = 1e-3                -- avoid division by zero

-- Center of view
local C_X = WINDOW_WIDTH / 2
local C_Y = 140 -- adjust to control horizon height

-- Project a point (x, y) with height h above table level
-- py uses (h + D)/xm so vertical scale also follows ~1/xm
function Perspective.project(x, y, h)
    local xm = (x - ORIGIN_X)
    if xm < EPS then xm = EPS end

    local ym = (y - FIELD_CENTER_Y)

    local px = S * (ym / xm) + C_X
    local py = S * ((h + D) / xm) + C_Y
    return px, py
end

-- Getter for screen center X (used to decide left/right side visibility)
function Perspective.center_x()
    return C_X
end

return Perspective

