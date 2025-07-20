-- Modular Pong main file
require "constants"
local Paddle = require "paddle"
local Ball = require "ball"
local AI = require "ai"
local collision = require "collision"

local player, opponent, ball
local playerScore, opponentScore
local gameState = "start"

-- Set opponent control mode here: "ai" or "manual"
local opponentControl = "manual"   -- Change to "ai" for single-player mode
local aiStrategy = AI.perfect      -- Default AI, used if opponentControl == "ai"
local bounceFunc = collision.bounceSimple

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
        -- Player 1 movement (Q/A)
        local dir = 0
        if love.keyboard.isDown('q') then dir = -1
        elseif love.keyboard.isDown('a') then dir = 1 end
        player:update(dt, dir)

        -- Opponent movement: AI or manual control
        local opponentDir = 0
        if opponentControl == "ai" then
            opponentDir = aiStrategy(ball, opponent)
        elseif opponentControl == "manual" then
            if love.keyboard.isDown('up') then opponentDir = -1
            elseif love.keyboard.isDown('down') then opponentDir = 1 end
        end
        opponent:update(dt, opponentDir)

        -- Ball update
        ball:update(dt)

        -- Top/bottom wall collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y + ball.size >= WINDOW_HEIGHT then
            ball.y = WINDOW_HEIGHT - ball.size
            ball.dy = -ball.dy
        end

        -- Paddle collision
        if collision.checkCollision(ball, player) then
            bounceFunc(ball, player)
            ball.x = player.x + player.width -- Avoid sticking
        elseif collision.checkCollision(ball, opponent) then
            bounceFunc(ball, opponent)
            ball.x = opponent.x - ball.size
        end

        -- Scoring
        if ball.x < 0 then
            opponentScore = opponentScore + 1
            ball:reset()
            if opponentScore >= WIN_SCORE then
                gameState = "done"
            end
        elseif ball.x + ball.size > WINDOW_WIDTH then
            playerScore = playerScore + 1
            ball:reset()
            if playerScore >= WIN_SCORE then
                gameState = "done"
            end
        end
    end
end

function love.draw()
    -- Draw background
    love.graphics.clear(COLOR_BG)
    love.graphics.setColor(COLOR_FG)

    -- Draw center line
    for y = 0, WINDOW_HEIGHT, BALL_SIZE * 2 do
        love.graphics.rectangle('fill', WINDOW_WIDTH / 2 - 2, y, 4, BALL_SIZE)
    end

    -- Draw paddles and ball
    player:draw()
    opponent:draw()
    ball:draw()

    -- Draw scores
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 60, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH / 2 + 40, SCORE_OFFSET_Y)

    -- Game state text
    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end

    -- Info about controls
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

           
       
        
