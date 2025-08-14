-- main.lua
require("constants")

local Perspective = require("perspective")
local Ball        = require("ball")
local Paddle      = require("paddle")

local player, enemy, puck
local uiFont, uiFontBig, uiFontSmall

--  visual constants 
local GRID_LINE_ALPHA   = 0.50
local GRID_LINE_WIDTH   = 1.2
local BRIGHT_LINE_WIDTH = 2.4
local FLOOR_HEIGHT      = 26   -- сетка/пол лежат на нижнем уровне бортика

-- Table --
do
    -- width as original shufflle puck
    local orig_x_near = 160
    local orig_x_far  = 560
    -- depth 
    local orig_y_min  = WINDOW_HEIGHT * 0.20
    local orig_y_max  = WINDOW_HEIGHT * 0.80
    local midY   = (orig_y_min + orig_y_max) / 2
    local half_h = (orig_y_max - orig_y_min) / 2 * 1.5
    TABLE = {
        x_near = orig_x_near,
        x_far  = orig_x_far,
        y_min  = midY - half_h,
        y_max  = midY + half_h,
    }
end

local X_MID      = (TABLE.x_near + TABLE.x_far) / 2
local GOAL_DEPTH = 8
local WIN_SCORE  = 10

-- speeds
local PLAYER_SPEED_Y = 320 -- across (Y axis)  A/D, ←/→
local PLAYER_SPEED_X = 260 -- depth (X axis)   W/S, ↑/↓

-- zones/grid
local OUTER_MARGIN = 12     -- total side clearance from outer edges (used only on far sides)
local INNER_MARGIN = 12     -- grid inset from its zone (but we push the near edges to the walls)
local CENTER_GAP   = 96     -- gap between sections

-- ASYMMETRICAL zone boundaries:
-- player: near edge = right at the wall, far edge left with a margin
local function zone_bounds_player()
    local halfGap = CENTER_GAP * 0.5
    local x1 = TABLE.x_near                -- без OUTER_MARGIN: press against the side
    local x2 = X_MID - halfGap - OUTER_MARGIN
    return x1, x2
end
-- enemy: near edge = at the gap, far edge = right at the wall
local function zone_bounds_enemy()
    local halfGap = CENTER_GAP * 0.5
    local x1 = X_MID + halfGap + OUTER_MARGIN
    local x2 = TABLE.x_far                 -- без OUTER_MARGIN: press against the wall
    return x1, x2
end

-- score/state
local scorePlayer, scoreEnemy = 0, 0
local state, serveDir, serveTimer = "play", 1, 0

--  SIDES  --
local function drawSideRails()
    local RAIL_TOP   = {0.70, 0.85, 0.95, 0.85} -- blue top shelf (z=0)
    local RAIL_SIDE  = {0.35, 0.50, 0.60, 0.85} -- inner vertical wall (0..FLOOR_HEIGHT)
    local EDGE_WHITE = {1, 1, 1, 1}

    local wNear = 140   -- width of the shelf at the near edge
    local wFar  = 60    -- at the far edge (narrowing)

    -- LEFT side (along TABLE.y_min)
    do
        local y_in  = TABLE.y_min
        local y_out_near = y_in - wNear
        local y_out_far  = y_in - wFar

        -- top inclined shelf (z=0)
        local a1x,a1y = Perspective.project(TABLE.x_near, y_in,        0)
        local a2x,a2y = Perspective.project(TABLE.x_far,  y_in,        0)
        local a3x,a3y = Perspective.project(TABLE.x_far,  y_out_far,   0)
        local a4x,a4y = Perspective.project(TABLE.x_near, y_out_near,  0)
        love.graphics.setColor(RAIL_TOP)
        love.graphics.polygon("fill", a1x,a1y, a2x,a2y, a3x,a3y, a4x,a4y)

        -- inner vertical wall: 0..FLOOR_HEIGHT
        local s1x,s1y = Perspective.project(TABLE.x_near, y_in, 0)
        local s2x,s2y = Perspective.project(TABLE.x_far,  y_in, 0)
        local s3x,s3y = Perspective.project(TABLE.x_far,  y_in, FLOOR_HEIGHT)
        local s4x,s4y = Perspective.project(TABLE.x_near, y_in, FLOOR_HEIGHT)
        love.graphics.setColor(RAIL_SIDE)
        love.graphics.polygon("fill", s1x,s1y, s2x,s2y, s3x,s3y, s4x,s4y)

        -- white edges
        love.graphics.setColor(EDGE_WHITE)
        love.graphics.setLineWidth(BRIGHT_LINE_WIDTH)
        love.graphics.line(a4x,a4y, a3x,a3y) -- outer edge of the shelf
        love.graphics.line(a1x,a1y, a2x,a2y) -- inner edge of the shelf
        love.graphics.line(s1x,s1y, s4x,s4y) -- vertical edges
        love.graphics.line(s2x,s2y, s3x,s3y)
    end

    -- RIGHT side (along TABLE.y_max)
    do
        local y_in  = TABLE.y_max
        local y_out_near = y_in + wNear
        local y_out_far  = y_in + wFar

        local b1x,b1y = Perspective.project(TABLE.x_near, y_in,        0)
        local b2x,b2y = Perspective.project(TABLE.x_far,  y_in,        0)
        local b3x,b3y = Perspective.project(TABLE.x_far,  y_out_far,   0)
        local b4x,b4y = Perspective.project(TABLE.x_near, y_out_near,  0)
        love.graphics.setColor(RAIL_TOP)
        love.graphics.polygon("fill", b1x,b1y, b2x,b2y, b3x,b3y, b4x,b4y)

        local t1x,t1y = Perspective.project(TABLE.x_near, y_in, 0)
        local t2x,t2y = Perspective.project(TABLE.x_far,  y_in, 0)
        local t3x,t3y = Perspective.project(TABLE.x_far,  y_in, FLOOR_HEIGHT)
        local t4x,t4y = Perspective.project(TABLE.x_near, y_in, FLOOR_HEIGHT)
        love.graphics.setColor(RAIL_SIDE)
        love.graphics.polygon("fill", t1x,t1y, t2x,t2y, t3x,t3y, t4x,t4y)

        love.graphics.setColor(EDGE_WHITE)
        love.graphics.setLineWidth(BRIGHT_LINE_WIDTH)
        love.graphics.line(b1x,b1y, b2x,b2y)
        love.graphics.line(b4x,b4y, b3x,b3y)
        love.graphics.line(t1x,t1y, t4x,t4y)
        love.graphics.line(t2x,t2y, t3x,t3y)
    end
end

--  Section grids (8×3) + perimeters and edges of the central strip --
local function drawPaddleZoneGridPerspective()
    local y0, y1 = TABLE.y_min, TABLE.y_max
    local DEPTH, WIDTH = 8, 3
    local fillA1, fillA2 = 0.10, 0.06

    -- side rails under the grid
    drawSideRails()

    -- drawZone with flags: alignNear/alignFar — should the grid be pressed against the zone boundary without INNER_MARGIN
    local function drawZone(xNear, xFar, alignNear, alignFar)
        local inNear = xNear + (alignNear and 0 or INNER_MARGIN)
        local inFar  = xFar  - (alignFar  and 0 or INNER_MARGIN)
        if inFar <= inNear then return end

        local xs, ys = {}, {}
        for i = 0, WIDTH do xs[i] = inNear + (inFar - inNear) * (i / WIDTH) end
        for j = 0, DEPTH do ys[j] = y0 + (y1 - y0) * (j / DEPTH) end

        -- tiles (ON THE FLOOR: z = FLOOR_HEIGHT)
        for j = 0, DEPTH - 1 do
            for i = 0, WIDTH - 1 do
                love.graphics.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3],
                                       ((i + j) % 2 == 0) and fillA1 or fillA2)
                local xL, xR = xs[i], xs[i+1]
                local yN, yF = ys[j], ys[j+1]
                local p1x, p1y = Perspective.project(xL, yN, FLOOR_HEIGHT)
                local p2x, p2y = Perspective.project(xR, yN, FLOOR_HEIGHT)
                local p3x, p3y = Perspective.project(xR, yF, FLOOR_HEIGHT)
                local p4x, p4y = Perspective.project(xL, yF, FLOOR_HEIGHT)
                love.graphics.polygon("fill", p1x,p1y, p2x,p2y, p3x,p3y, p4x,p4y)
            end
        end

        -- inner grid (ON THE FLOOR)
        love.graphics.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3], GRID_LINE_ALPHA)
        love.graphics.setLineWidth(GRID_LINE_WIDTH)
        for i = 1, WIDTH - 1 do
            local xx = inNear + (inFar - inNear) * (i / WIDTH)
            local a1x, a1y = Perspective.project(xx, y0, FLOOR_HEIGHT)
            local a2x, a2y = Perspective.project(xx, y1, FLOOR_HEIGHT)
            love.graphics.line(a1x, a1y, a2x, a2y)
        end
        for j = 1, DEPTH - 1 do
            local yy = y0 + (y1 - y0) * (j / DEPTH)
            local b1x, b1y = Perspective.project(inNear, yy, FLOOR_HEIGHT)
            local b2x, b2y = Perspective.project(inFar,  yy, FLOOR_HEIGHT)
            love.graphics.line(b1x, b1y, b2x, b2y)
        end

        -- bright perimeter of the section (ON THE FLOOR)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(BRIGHT_LINE_WIDTH)
        local z1x, z1y = Perspective.project(inNear, y0, FLOOR_HEIGHT)
        local z2x, z2y = Perspective.project(inFar,  y0, FLOOR_HEIGHT)
        local z3x, z3y = Perspective.project(inFar,  y1, FLOOR_HEIGHT)
        local z4x, z4y = Perspective.project(inNear, y1, FLOOR_HEIGHT)
        love.graphics.line(z1x, z1y, z2x, z2y)
        love.graphics.line(z2x, z2y, z3x, z3y)
        love.graphics.line(z3x, z3y, z4x, z4y)
        love.graphics.line(z4x, z4y, z1x, z1y)

        return inNear, inFar
    end

    local px1, px2 = zone_bounds_player()
    local ex1, ex2 = zone_bounds_enemy()
    -- player: press the near edge to the side
    local pInNear, pInFar = drawZone(px1, px2, true,  false)
    -- enemy: press the far edge to the side
    local eInNear, eInFar = drawZone(ex1, ex2, false, true)

    -- edges of the central strip (ON THE FLOOR) — as they were
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(BRIGHT_LINE_WIDTH)
    if pInFar then
        local a1x, a1y = Perspective.project(pInFar, y0, FLOOR_HEIGHT)
        local a2x, a2y = Perspective.project(pInFar, y1, FLOOR_HEIGHT)
        love.graphics.line(a1x, a1y, a2x, a2y)
    end
    if eInNear then
        local b1x, b1y = Perspective.project(eInNear, y0, FLOOR_HEIGHT)
        local b2x, b2y = Perspective.project(eInNear, y1, FLOOR_HEIGHT)
        love.graphics.line(b1x, b1y, b2x, b2y)
    end
end

-- Game logic / collisions -- 
local function collidePaddleSwept(puck, paddle, dt)
    local goingLeft  = puck.dx < 0 and paddle.x <= puck.x
    local goingRight = puck.dx > 0 and paddle.x >= puck.x
    if not (goingLeft or goingRight) then return false end

    local t = (paddle.x - puck.x) / puck.dx
    if t < 0 or t > dt then return false end

    local y_at_hit = puck.y + puck.dy * t
    local halfY = (paddle.w or 40) * 0.5
    local hit = (y_at_hit >= paddle.y - halfY - puck.r) and (y_at_hit <= paddle.y + halfY + puck.r)
    if not hit then return false end

    puck.x, puck.y = paddle.x, y_at_hit
    puck.dx = -puck.dx
    local offset = (y_at_hit - paddle.y) / halfY
    puck.dy = puck.dy + offset * 220
    puck.dx, puck.dy = puck.dx * 1.04, puck.dy * 1.04
    if goingLeft then puck.x = paddle.x + 1 else puck.x = paddle.x - 1 end
    return true
end

local function bounceWallsY(p)
    if p.y - p.r < TABLE.y_min then p.y = TABLE.y_min + p.r; p.dy = -p.dy
    elseif p.y + p.r > TABLE.y_max then p.y = TABLE.y_max - p.r; p.dy = -p.dy end
end

local function goalSide(p)
    if p.x <= (TABLE.x_near - GOAL_DEPTH) then return -1
    elseif p.x >= (TABLE.x_far + GOAL_DEPTH) then return 1 end
    return 0
end

local function centerAndStopPuck()
    puck.x = (TABLE.x_near + TABLE.x_far) / 2
    puck.y = (TABLE.y_min  + TABLE.y_max) / 2
    puck.dx, puck.dy = 0, 0
end

local function resetPuck(dir)
    puck.x = (TABLE.x_near + TABLE.x_far) / 2
    puck.y = (TABLE.y_min  + TABLE.y_max) / 2
    local baseSpeedX, baseSpeedY = 220, 130
    puck.dx = baseSpeedX * (dir >= 0 and 1 or -1)
    puck.dy = (love.math.random() < 0.5 and -1 or 1) * baseSpeedY
end

--  LÖVE --
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=false})
    love.graphics.setBackgroundColor(COLOR_BG)
    uiFont      = love.graphics.newFont(36)
    uiFontBig   = love.graphics.newFont(64)
    uiFontSmall = love.graphics.newFont(22)

    local px1, px2 = zone_bounds_player()
    local ex1, ex2 = zone_bounds_enemy()
    player = Paddle.new(px1 + 40, (TABLE.y_min + TABLE.y_max)/2, 52, 42)
    enemy  = Paddle.new(ex2 - 40, (TABLE.y_min + TABLE.y_max)/2, 48, 38)

    puck   = Ball.new((TABLE.x_near + TABLE.x_far)/2, (TABLE.y_min + TABLE.y_max)/2, 220, 130, 18)
    puck.thickness = 18
end

function love.update(dt)
    if dt > 0.033 then dt = 0.033 end

    -- control (inverted axes)
    local k = love.keyboard.isDown
    local moveDepth = (k("w") and 1 or 0) + (k("s") and -1 or 0)
    moveDepth = moveDepth + (k("up") and 1 or 0) + (k("down") and -1 or 0)
    player.x = player.x + moveDepth * PLAYER_SPEED_X * dt

    local moveWidth = (k("a") and -1 or 0) + (k("d") and 1 or 0)
    moveWidth = moveWidth + (k("left") and -1 or 0) + (k("right") and 1 or 0)
    player.y = player.y + moveWidth * PLAYER_SPEED_Y * dt

    -- clamps the player zone
    do
        local halfY = (player.w or 40) * 0.5
        if player.y < TABLE.y_min + halfY then player.y = TABLE.y_min + halfY end
        if player.y > TABLE.y_max - halfY then player.y = TABLE.y_max - halfY end
        local px1, px2 = zone_bounds_player()
        local leftB, rightB = px1 + INNER_MARGIN, px2 - INNER_MARGIN
        if rightB < leftB then rightB = leftB end
        if player.x < leftB then player.x = leftB end
        if player.x > rightB then player.x = rightB end
    end

    -- enemy (demo)
    enemy.x = (function() local ex1,ex2=zone_bounds_enemy(); return ex1+(ex2-ex1)*0.75 end)()
    enemy.y = (TABLE.y_min + TABLE.y_max)/2 + math.sin(love.timer.getTime()*1.2) * (TABLE.y_max - TABLE.y_min) * 0.28
    do
        local halfY = (enemy.w or 40) * 0.5
        if enemy.y < TABLE.y_min + halfY then enemy.y = TABLE.y_min + halfY end
        if enemy.y > TABLE.y_max - halfY then enemy.y = TABLE.y_max - halfY end
        local ex1, ex2 = zone_bounds_enemy()
        local leftB, rightB = ex1 + INNER_MARGIN, ex2 - INNER_MARGIN
        if rightB < leftB then rightB = leftB end
        if enemy.x < leftB then enemy.x = leftB end
        if enemy.x > rightB then enemy.x = rightB end
    end

    -- FSM / puck
    if state == "over" then
        centerAndStopPuck(); return
    elseif state == "serve" then
        centerAndStopPuck()
        serveTimer = serveTimer - dt
        if serveTimer <= 0 then resetPuck(serveDir); state = "play" end
        return
    end

    local hitP = collidePaddleSwept(puck, player, dt)
    local hitE = collidePaddleSwept(puck, enemy,  dt)
    if not (hitP or hitE) then puck:update(dt) end
    bounceWallsY(puck)

    local side = goalSide(puck)
    if side ~= 0 then
        if side == 1 then scorePlayer = scorePlayer + 1 else scoreEnemy = scoreEnemy + 1 end
        if scorePlayer >= WIN_SCORE or scoreEnemy >= WIN_SCORE then
            state = "over"; centerAndStopPuck()
        else
            state = "serve"; serveDir = side; serveTimer = 0.7
        end
    end
end

function love.draw()
    -- sides + nets (all at floor level) + perimeters
    drawPaddleZoneGridPerspective()

    -- paddles and puck
    love.graphics.setColor(COLOR_FG)
    player:drawPerspective()
    enemy:drawPerspective()
    puck:drawPerspective()

    -- scoreboard
    love.graphics.setFont(uiFontBig)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(string.format("%d:%d", scorePlayer, scoreEnemy), 20, 14)

    -- GAME OVER screen
    if state == "over" then
        love.graphics.setColor(0, 0, 0, 0.45)
        love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(uiFontBig)
        local title = "GAME OVER"
        local tw = uiFontBig:getWidth(title)
        local th = uiFontBig:getHeight()
        love.graphics.print(title, (WINDOW_WIDTH - tw) / 2, (WINDOW_HEIGHT - th) / 2 - 28)

        love.graphics.setFont(uiFontSmall)
        local hint = "Press SPACE to restart"
        local hw = uiFontSmall:getWidth(hint)
        love.graphics.print(hint, (WINDOW_WIDTH - hw) / 2, (WINDOW_HEIGHT + th) / 2 + 4)
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "space" and state == "over" then
        scorePlayer, scoreEnemy = 0, 0
        state = "serve"
        serveDir = (love.math.random() < 0.5) and -1 or 1
        serveTimer = 0.7
    end
end


  
       

       

   
 
      
  

         
 



       
 
     
      
  
  

        

    
           
      
           
       



           
       
        
