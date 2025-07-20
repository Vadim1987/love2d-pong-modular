-- AI module with multiple strategies

local AI = {}

function AI.perfect(ball, paddle)
    -- Always centers paddle on the ball's y position (perfect)
    if ball.y + ball.size / 2 < paddle.y + paddle.height / 2 then
        return -1
    elseif ball.y + ball.size / 2 > paddle.y + paddle.height / 2 then
        return 1
    else
        return 0
    end
end

function AI.random(ball, paddle)
    -- Ignores ball, moves randomly
    return math.random(-1, 1)
end

function AI.follow_slow(ball, paddle)
    -- Follows, but with a dead zone (sloppy)
    local centerDiff = (ball.y + ball.size / 2) - (paddle.y + paddle.height / 2)
    if math.abs(centerDiff) > 10 then
        return centerDiff > 0 and 1 or -1
    else
        return 0
    end
end

function AI.novice(ball, paddle)
    -- Just sits in the middle like a beginner
    if paddle.y + paddle.height / 2 < WINDOW_HEIGHT / 2 - 5 then
        return 1
    elseif paddle.y + paddle.height / 2 > WINDOW_HEIGHT / 2 + 5 then
        return -1
    else
        return 0
    end
end

return AI
