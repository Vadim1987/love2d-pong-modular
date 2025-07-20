WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) settings
PADDLE_WIDTH = 18
PADDLE_HEIGHT = 60
PADDLE_SPEED = 280 -- Both axes

-- Grid for movement limits (player zone only)
GRID_X = 8
GRID_Y = 3
BAT_MIN_X = 40
BAT_MAX_X = (WINDOW_WIDTH / 2) - PADDLE_WIDTH - 20
BAT_MIN_Y = (WINDOW_HEIGHT / 2) - 100
BAT_MAX_Y = (WINDOW_HEIGHT / 2) + 100 - PADDLE_HEIGHT

-- Ball (puck) settings
BALL_SIZE = 16 -- radius
BALL_SPEED_X = 220
BALL_SPEED_Y = 120

-- Perspective rendering constants
PROJ_S = 300
PROJ_D = 650
PROJ_CX = WINDOW_WIDTH / 2
PROJ_CY = 0
BAT_HEIGHT_3D = 40 -- bat in 3D (drawn as 3D bar)
PUCK_HEIGHT_3D = 15 -- puck is lower

-- Score
WIN_SCORE = 10
SCORE_OFFSET_Y = 40

-- Colors
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}


