-- Window
WINDOW_WIDTH  = 800
WINDOW_HEIGHT = 600

-- Player paddle (bat) : slim & proportional for Shufflepuck feel
PADDLE_WIDTH  = 14
PADDLE_HEIGHT = 52
PADDLE_SPEED  = 340     -- movement speed along both local axes

-- Player movement zone (the "near half" of the table)
-- X here is the depth axis (away from the player), Y is lateral
-- We restrict player to this box.
ZONE_MIN_X = 100
ZONE_MAX_X = 360
ZONE_MIN_Y = 140
ZONE_MAX_Y = 460 - PADDLE_HEIGHT

-- Grid (8 x 3) drawn over the allowed zone
GRID_COLS = 8
GRID_ROWS = 3

-- Ball (puck)
BALL_RADIUS  = 10
BALL_SPEED_X = 190
BALL_SPEED_Y = 115

-- Perspective constants (formula: f(x,y) = s * (ym + d/xm, h + d/xm) + c)
-- xm = (x - ORIGIN_X), ym = (y - FIELD_CENTER_Y)
PROJ_SCALE = 120     -- s
PROJ_DIST  = 170     -- d : "distance to projection plane"
PROJ_CX    = WINDOW_WIDTH / 2  -- c.x (center of view horizontally)
PROJ_CY    = 70                -- c.y (slightly down from top for aesthetic)

-- Origin offsets for perspective
ORIGIN_X        = ZONE_MIN_X   -- where xm = 0 (player's eye X plane)
FIELD_CENTER_Y  = (ZONE_MIN_Y + ZONE_MAX_Y) / 2

-- Heights (h) for objects
BAT_HEIGHT_3D  = 24
PUCK_HEIGHT_3D = 10

-- Scoring
WIN_SCORE      = 10
SCORE_OFFSET_Y = 34

-- Colors
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}


