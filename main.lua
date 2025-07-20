require "constants"
require "utils"
local Paddle = require "paddle"
local Ball = require "ball"
local collision = require "collision"

local player, ball
local playerScore, opponentScore
local gameState = "start"

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    math.randomseed(os.time())
    player = Paddle:create((BAT_MIN_X + BAT_MAX_X) / 2, (BAT_MIN_Y + BAT_MAX_Y) / 2)
    ball = Ball:create()
    playerScore, opponentScore = 0, 0
end

function love.update(dt)
    if gameState == "play" then
        -- WASD: W/S = depth (table axis, forward/back), A/D = width (screen horizontal)
        local vdir, hdir = 0, 0
        if love.keyboard.isDown('w') then vdir = -1 elseif love.keyboard.isDown('s') then vdir = 1 end
        if love.keyboard.isDown('a') then hdir = -1 elseif love.keyboard.isDown('d') then hdir = 1 end
        player:update(dt, vdir, hdir)

        -- Restrict player to near half only
        player.x = math.max(BAT_MIN_X, math.min(BAT_MAX_X, player.x))
        player.y = math.max(BAT_MIN_Y, math.min(BAT_MAX_Y, player.y))

        ball:update(dt)

        -- Walls (side bumpers)
        if ball.y - ball.radius <= BAT_MIN_Y then
            ball.y = BAT_MIN_Y + ball.radius
            ball.dy = -ball.dy
        elseif ball.y + ball.radius >= BAT_MAX_Y + PADDLE_HEIGHT then
            ball.y = BAT_MAX_Y + PADDLE_HEIGHT - ball.radius
            ball.dy = -ball.dy
        end

        -- Paddle collision (player side only)
        if collision.sweptCollision(ball, player) then
            collision.bounceClean(ball, player)
            local closestX = math.max(player.x, math.min(ball.x, player.x + player.width))
            local closestY = math.max(player.y, math.min(ball.y, player.y + player.height))
            local nx = ball.x - closestX
            local ny = ball.y - closestY
            local len = math.sqrt(nx*nx + ny*ny)
            if len == 0 then len = 1 end
            ball.x = closestX + nx / len * (ball.radius + 1)
            ball.y = closestY + ny / len * (ball.radius + 1)
        end

        -- "Goal": ball crosses center or returns back (opponent/your point)
        if ball.x - ball.radius > WINDOW_WIDTH / 2 then
            opponentScore = opponentScore + 1
            ball:reset()
            if opponentScore >= WIN_SCORE then
                gameState = "done"
            end
        elseif ball.x + ball.radius < BAT_MIN_X then
            playerScore = playerScore + 1
            ball:reset()
            if playerScore >= WIN_SCORE then
                gameState = "done"
            end
        end
    end
end

function love.draw()
    love.graphics.clear(COLOR_BG)
    love.graphics.setColor(COLOR_FG)

    -- Draw grid on allowed movement area (player's half)
    for gx = 0, GRID_X do
        for gy = 0, GRID_Y do
            local fx = BAT_MIN_X + gx * ((BAT_MAX_X - BAT_MIN_X) / GRID_X)
            local fy = BAT_MIN_Y + gy * ((BAT_MAX_Y - BAT_MIN_Y) / GRID_Y)
            local sx, sy = perspective(fx, fy, 0)
            if gx > 0 then
                local fx2 = BAT_MIN_X + (gx - 1) * ((BAT_MAX_X - BAT_MIN_X) / GRID_X)
                local sx2, sy2 = perspective(fx2, fy, 0)
                love.graphics.line(sx, sy, sx2, sy2)
            end
            if gy > 0 then
                local fy2 = BAT_MIN_Y + (gy - 1) * ((BAT_MAX_Y - BAT_MIN_Y) / GRID_Y)
                local sx2, sy2 = perspective(fx, fy2, 0)
                love.graphics.line(sx, sy, sx2, sy2)
            end
        end
    end

    -- Draw player's bat (as a 3D rectangle)
    local px1, py1 = perspective(player.x, player.y, BAT_HEIGHT_3D)
    local px2, py2 = perspective(player.x + player.width, player.y + player.height, 0)
    love.graphics.rectangle("fill", px1, py1, px2 - px1, py2 - py1)

    -- Draw puck (as a circle, lower)
    local bx, by = perspective(ball.x, ball.y, PUCK_HEIGHT_3D)
    love.graphics.circle("fill", bx, by, ball.radius)

    -- Scoreboard (center top)
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 40, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH / 2 + 20, SCORE_OFFSET_Y)

    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end

    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.print("Move: WASD | Start: Space | Quit: Esc", 20, WINDOW_HEIGHT - 28)
    love.graphics.setColor(COLOR_FG)
end

function love.keypressed(key)
    if key == 'space' then
        if gameState ~= "play" then
            playerScore, opponentScore = 0, 0
            ball:reset()
            gameState = "play"
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end

     
         

    
   


 
    
         
            
      
  
  

        

    
           
      
           
       



           
       
        
