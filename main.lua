require "constants"
local Paddle = require "paddle"
local Ball = require "ball"
local AI = require "ai"
local collision = require "collision"

local player, opponent, ball
local playerScore, opponentScore
local gameState = "start"

local opponentControl = "ai"
local aiStrategy = AI.basic

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    math.randomseed(os.time())
    player = Paddle:create(PADDLE_OFFSET_X, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, true, false)
    opponent = Paddle:create(WINDOW_WIDTH - PADDLE_OFFSET_X - PADDLE_WIDTH, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, false, true)
    ball = Ball:create()
    playerScore, opponentScore = 0, 0
end

function love.update(dt)
    if gameState == "play" then
        -- WASD: W/S = up/down, A/D = left/right (player)
        local vdir, hdir = 0, 0
        if love.keyboard.isDown('w') then vdir = -1 elseif love.keyboard.isDown('s') then vdir = 1 end
        if love.keyboard.isDown('a') then hdir = -1 elseif love.keyboard.isDown('d') then hdir = 1 end
        player:update(dt, vdir, hdir)

        -- Opponent: AI or manual
        local ovdir, ohdir = 0, 0
        if opponentControl == "ai" then
            ovdir, ohdir = aiStrategy(ball, opponent)
        elseif opponentControl == "manual" then
            if love.keyboard.isDown('up') then ovdir = -1 elseif love.keyboard.isDown('down') then ovdir = 1 end
            if love.keyboard.isDown('left') then ohdir = -1 elseif love.keyboard.isDown('right') then ohdir = 1 end
        end
        opponent:update(dt, ovdir, ohdir)

        ball:update(dt)

        
        if ball.y - ball.radius <= 0 then
            ball.y = ball.radius
            ball.dy = -ball.dy
        elseif ball.y + ball.radius >= WINDOW_HEIGHT then
            ball.y = WINDOW_HEIGHT - ball.radius
            ball.dy = -ball.dy
        end

        
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
        elseif collision.sweptCollision(ball, opponent) then
            collision.bounceClean(ball, opponent)
            local closestX = math.max(opponent.x, math.min(ball.x, opponent.x + opponent.width))
            local closestY = math.max(opponent.y, math.min(ball.y, opponent.y + opponent.height))
            local nx = ball.x - closestX
            local ny = ball.y - closestY
            local len = math.sqrt(nx*nx + ny*ny)
            if len == 0 then len = 1 end
            ball.x = closestX + nx / len * (ball.radius + 1)
            ball.y = closestY + ny / len * (ball.radius + 1)
        end

        -- Голы
        if ball.x + ball.radius < 0 then
            opponentScore = opponentScore + 1
            ball:reset()
            if opponentScore >= WIN_SCORE then
                gameState = "done"
            end
        elseif ball.x - ball.radius > WINDOW_WIDTH then
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
    for y = 0, WINDOW_HEIGHT, BALL_SIZE * 2 do
        love.graphics.rectangle('fill', WINDOW_WIDTH / 2 - 2, y, 4, BALL_SIZE)
    end
    player:draw()
    opponent:draw()
    ball:draw()
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 60, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH / 2 + 40, SCORE_OFFSET_Y)
    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end
    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.print(
        "Left: WASD | Right: Arrows | Start: Space | Quit: Esc",
        20, WINDOW_HEIGHT - 28
    )
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

    
         
            
      
  
  

        

    
           
      
           
       



           
       
        
