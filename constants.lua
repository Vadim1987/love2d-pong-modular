WINDOW_WIDTH  = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) settings
PADDLE_WIDTH  = 14
PADDLE_HEIGHT = 52
PADDLE_SPEED  = 340

-- Player movement zone (near half of the table)
ZONE_MIN_X = 100
ZONE_MAX_X = 360
ZONE_MIN_Y = 140
ZONE_MAX_Y = 460 - PADDLE_HEIGHT

-- Grid
GRID_COLS = 8
GRID_ROWS = 3

-- Ball (puck)
BALL_RADIUS  = 10
BALL_SPEED_X = 190
BALL_SPEED_Y = 115

-- Perspective projection constants
PROJ_SCALE = 120
PROJ_DIST  = 170
PROJ_CX    = WINDOW_WIDTH  / 2
PROJ_CY    = 80

-- Origin offsets for projection
ORIGIN_X       = ZONE_MIN_X
FIELD_CENTER_Y = (ZONE_MIN_Y + ZONE_MAX_Y) / 2

-- Heights for 3D effect
BAT_HEIGHT_3D  = 24
PUCK_HEIGHT_3D = 10

-- Scoring
WIN_SCORE      = 10
SCORE_OFFSET_Y = 34

-- Colors
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}


