-- constants.lua
-- Game window
WINDOW_WIDTH  = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) parameters
PADDLE_WIDTH   = 10
PADDLE_HEIGHT  = 60
PADDLE_SPEED   = 300
PADDLE_HSPEED  = 200

-- Horizontal limits (legacy 2D; not used by perspective flow directly)
BAT_MIN_X = 0
BAT_MAX_X = (WINDOW_WIDTH / 2) - PADDLE_WIDTH - 10
OPP_MIN_X = (WINDOW_WIDTH / 2) + 10
OPP_MAX_X = WINDOW_WIDTH - PADDLE_WIDTH

-- Ball (2D baseline)
BALL_RADIUS_X = 16
BALL_RADIUS_Y = 10
BALL_SPEED_X = 240
BALL_SPEED_Y = 120

-- Score
WIN_SCORE = 10

-- Offsets & display
PADDLE_OFFSET_X = 30
SCORE_OFFSET_Y  = 40

-- Colors: baseline (iteration 1)
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}

-- ===== Height planes =====
-- Table plane: h = 0 (implicit)
H_PUCK = 10               -- top of puck (iteration 2/3)
H_BAT  = H_PUCK * 3       -- top of bats (iteration 2/3)

-- ===== Iteration 2/3 colors =====
-- Puck top + wall share same color family
COLOR_PUCK_TOP_FILL    = {0.85, 0.95, 1.00, 1.0}
COLOR_PUCK_TOP_OUTLINE = {0.10, 0.12, 0.16, 1.0}

-- Bat tops
COLOR_BAT_TOP_FILL     = {0.95, 0.90, 0.20, 1.0}
COLOR_BAT_TOP_OUTLINE  = {0.10, 0.10, 0.10, 1.0}

-- Bat vertical sides (iteration 3) — solid, no gradients
COLOR_BAT_SIDE_FILL    = {0.92, 0.92, 0.92, 1.0}
COLOR_BAT_SIDE_OUTLINE = {0.0,  0.0,  0.0,  1.0}


