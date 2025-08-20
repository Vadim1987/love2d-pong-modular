-- constants.lua
-- Game window
WINDOW_WIDTH  = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) parameters (base footprint on the table)
PADDLE_WIDTH   = 10
PADDLE_HEIGHT  = 60
PADDLE_SPEED   = 300     -- Vertical movement
PADDLE_HSPEED  = 200     -- Horizontal movement

-- Horizontal limits (not beyond half of the table)
BAT_MIN_X = 0
BAT_MAX_X = (WINDOW_WIDTH / 2) - PADDLE_WIDTH - 10
OPP_MIN_X = (WINDOW_WIDTH / 2) + 10
OPP_MAX_X = WINDOW_WIDTH - PADDLE_WIDTH

-- Ball (ellipse radii for classic 2D mode — not used in perspective draw)
BALL_RADIUS_X = 16
BALL_RADIUS_Y = 10

BALL_SPEED_X = 240
BALL_SPEED_Y = 120

-- Score
WIN_SCORE = 10

-- Offsets and display
PADDLE_OFFSET_X = 30
SCORE_OFFSET_Y  = 40

-- Colors (base iteration is black&white)
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}

-- ===== Height planes for iteration 2 (no side faces) =====
-- Top plane of puck above the table
H_PUCK = 10
-- Top plane of bats above the puck top (3× puck height)
H_BAT  = H_PUCK * 3

-- Color scheme for iteration 2 planes
-- Keep base on table black/white; use distinct colors for tops:
COLOR_PUCK_TOP_FILL    = {0.85, 0.95, 1.00, 1.0}  -- soft icy
COLOR_PUCK_TOP_OUTLINE = {0.10, 0.12, 0.16, 1.0}

COLOR_BAT_TOP_FILL     = {0.95, 0.90, 0.20, 1.0}  -- warm accent
COLOR_BAT_TOP_OUTLINE  = {0.10, 0.10, 0.10, 1.0}

