-- Modular Pong main file (circular puck, swept collision, tangent bounce)
require "constants"
local Paddle = require "paddle"
local Ball = require "ball"
local AI = require "ai"
local collision = require "collision"

local player, opponent, ball
local playerScore, opponentScore
local gameState = "start"

-- Switch between "ai" or "manual" for opponent
local opponentControl = "manual"
local aiStrategy = AI.perfect
local bounceFunc = collision.bounceTangent

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    math.randomseed(os.time())
    player = Paddle:create(PADDLE_OFFSET_X, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, true)
    opponent = Paddle:create(WINDOW_WIDTH - PADDLE_OFFSET_X - PADDLE_WIDTH, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, false)
    ball = Ball:create()
    playerScore, opponentScore = 0, 0
end

function love.update(dt)
    if gameState == "play" then
        -- Player 1 controls (Q/A)
        local dir = 0
        if love.keyboard.isDown('q') then dir = -1
        elseif love.keyboard.isDown('a') then dir = 1 end
        player:update(dt, dir)

        -- Opponent controls: AI or manual (arrows)
        local opponentDir = 0
        if opponentControl == "ai" then
            opponentDir = aiStrategy(ball, opponent)
        elseif opponentControl == "manual" then
            if love.keyboard.isDown('up') then opponentDir = -1
            elseif love.keyboard.isDown('down') then opponentDir = 1 end
        end
        opponent:update(dt, opponentDir)

        -- Ball update (track previous position for swept collision)
        ball:update(dt)

        -- Top/bottom wall collision for circle
        if ball.y - ball.radius <= 0 then
            ball.y = ball.radius
            ball.dy = -ball.dy
        elseif ball.y + ball.radius >= WINDOW_HEIGHT then
            ball.y = WINDOW_HEIGHT - ball.radius
            ball.dy = -ball.dy
        end

        -- Swept paddle collision: check along trajectory to prevent tunneling
        if collision.sweptCollision(ball, player) then
            collision.bounceTangent(ball, player)
            -- Move out along normal to prevent sticking
            local closestX = math.max(player.x, math.min(ball.x, player.x + player.width))
            local closestY = math.max(player.y, math.min(ball.y, player.y + player.height))
            local nx = ball.x - closestX
            local ny = ball.y - closestY
            local len = math.sqrt(nx*nx + ny*ny)
            if len == 0 then len = 1 end
            ball.x = closestX + nx / len * (ball.radius + 1)
            ball.y = closestY + ny / len * (ball.radius + 1)
        elseif collision.sweptCollision(ball, opponent) then
            collision.bounceTangent(ball, opponent)
            local closestX = math.max(opponent.x, math.min(ball.x, opponent.x + opponent.width))
            local closestY = math.max(opponent.y, math.min(ball.y, opponent.y + opponent.height))
            local nx = ball.x - closestX
            local ny = ball.y - closestY
            local len = math.sqrt(nx*nx + ny*ny)
            if len == 0 then len = 1 end
            ball.x = closestX + nx / len * (ball.radius + 1)
            ball.y = closestY + ny / len * (ball.radius + 1)
        end

        -- Scoring: check if ball left the screen (circle logic)
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
    -- Background
    love.graphics.clear(COLOR_BG)
    love.graphics.setColor(COLOR_FG)

    -- Center dotted line
    for y = 0, WINDOW_HEIGHT, BALL_SIZE * 2 do
        love.graphics.rectangle('fill', WINDOW_WIDTH / 2 - 2, y, 4, BALL_SIZE)
    end

    -- Paddles & puck
    player:draw()
    opponent:draw()
    ball:draw()

    -- Scores
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 60, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH / 2 + 40, SCORE_OFFSET_Y)

    -- Game state messages
    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end

    -- Controls help
    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.print(
        "Left: Q/A | Right: Up/Down | Start: Space | Quit: Esc",
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

    
           
      
           
       



           
       
        
