-- Modular Pong main file

require "constants"
local Paddle = require "paddle"
local Ball = require "ball"
local AI = require "ai"
local collision = require "collision"

local player, computer, ball
local playerScore, computerScore
local gameState = "start"
local aiStrategy = AI.perfect  -- Change to any other strategy for fun!
local bounceFunc = collision.bounceSimple

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    math.randomseed(os.time())
    player = Paddle:create(PADDLE_OFFSET_X, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, true)
    computer = Paddle:create(WINDOW_WIDTH - PADDLE_OFFSET_X - PADDLE_WIDTH, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, false)
    ball = Ball:create()
    playerScore, computerScore = 0, 0
end

function love.update(dt)
    if gameState == "play" then
        -- Player movement (Q/A)
        local dir = 0
        if love.keyboard.isDown('q') then dir = -1
        elseif love.keyboard.isDown('a') then dir = 1 end
        player:update(dt, dir)

        -- Computer movement (AI)
        local aiDir = aiStrategy(ball, computer)
        computer:update(dt, aiDir)

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
        elseif collision.checkCollision(ball, computer) then
            bounceFunc(ball, computer)
            ball.x = computer.x - ball.size
        end

        -- Scoring
        if ball.x < 0 then
            computerScore = computerScore + 1
            ball:reset()
            if computerScore >= WIN_SCORE then
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
    computer:draw()
    ball:draw()

    -- Draw scores
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 60, SCORE_OFFSET_Y)
    love.graphics.print(tostring(computerScore), WINDOW_WIDTH / 2 + 40, SCORE_OFFSET_Y)

    -- Game over text
    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end
end

function love.keypressed(key)
    if key == 'space' then
        if gameState ~= "play" then
            playerScore, computerScore = 0, 0
            ball:reset()
            gameState = "play"
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end
