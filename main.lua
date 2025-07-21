require "constants"
require "utils"
local Paddle    = require "paddle"
local Ball      = require "ball"
local collision = require "collision"

local player, ball
local playerScore, opponentScore = 0, 0
local gameState = "play"  -- <<-- auto-start

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    player = Paddle:new((ZONE_MIN_X+ZONE_MAX_X)/2, (ZONE_MIN_Y+ZONE_MAX_Y)/2)
    ball   = Ball:new()
end

function love.update(dt)
    if gameState ~= "play" then return end

    -- Controls: W/S = depth (x), A/D = lateral (y)
    local vdir, hdir = 0,0
    if love.keyboard.isDown("w") then vdir=-1 elseif love.keyboard.isDown("s") then vdir=1 end
    if love.keyboard.isDown("a") then hdir=-1 elseif love.keyboard.isDown("d") then hdir=1 end
    player:update(dt, vdir, hdir)

    ball:update(dt)

    -- Side walls
    if ball.y - ball.radius <= ZONE_MIN_Y then
        ball.y, ball.dy = ZONE_MIN_Y + ball.radius, -ball.dy
    elseif ball.y + ball.radius >= ZONE_MAX_Y + PADDLE_HEIGHT then
        ball.y, ball.dy = ZONE_MAX_Y + PADDLE_HEIGHT - ball.radius, -ball.dy
    end

    -- Paddle collision
    if collision.swept_collision(ball, player) then
        collision.bounce_normal(ball, player)
    end

    -- Goals
    if ball.x - ball.radius > WINDOW_WIDTH/2 then
        opponentScore = opponentScore + 1
        ball:reset()
        if opponentScore >= WIN_SCORE then gameState = "done" end
    elseif ball.x + ball.radius < ZONE_MIN_X then
        playerScore = playerScore + 1
        ball:reset()
        if playerScore >= WIN_SCORE then gameState = "done" end
    end
end

function love.draw()
    love.graphics.clear(COLOR_BG)
    love.graphics.setColor(COLOR_FG)

    -- Draw grid
    for gx=0,GRID_COLS do
      for gy=0,GRID_ROWS do
        local wx = ZONE_MIN_X + (ZONE_MAX_X-ZONE_MIN_X)*(gx/GRID_COLS)
        local wy = ZONE_MIN_Y + (ZONE_MAX_Y-ZONE_MIN_Y)*(gy/GRID_ROWS)
        local sx,sy = project_to_screen(wx,wy,0)
        if gx>0 then
          local pwx = ZONE_MIN_X + (ZONE_MAX_X-ZONE_MIN_X)*((gx-1)/GRID_COLS)
          local psx,psy = project_to_screen(pwx,wy,0)
          love.graphics.line(sx,sy, psx,psy)
        end
        if gy>0 then
          local pwy = ZONE_MIN_Y + (ZONE_MAX_Y-ZONE_MIN_Y)*((gy-1)/GRID_ROWS)
          local vsx,vsy = project_to_screen(wx,pwy,0)
          love.graphics.line(sx,sy, vsx,vsy)
        end
      end
    end

    -- Draw paddle slab
    draw_perspective_rect(
      player.x, player.y,
      player.x+player.width, player.y+player.height,
      BAT_HEIGHT_3D, 0
    )

    -- Draw puck
    local bx,by = project_to_screen(ball.x, ball.y, PUCK_HEIGHT_3D)
    love.graphics.circle("fill", bx, by, ball.radius)

    -- Score
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH/2-50, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH/2+30, SCORE_OFFSET_Y)

    if gameState=="done" then
      love.graphics.printf("Game Over",0,WINDOW_HEIGHT/2-16,WINDOW_WIDTH,"center")
    end

    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.print(
      "W/S = depth, A/D = lateral | Esc = quit",
      20, WINDOW_HEIGHT-28
    )
end

function love.keypressed(k)
    if k=="escape" then love.event.quit() end
    if k=="space" then
      playerScore,opponentScore=0,0
      ball:reset()
      gameState="play"
    end
end

      
  

         
 



       
 
     
      
  
  

        

    
           
      
           
       



           
       
        
