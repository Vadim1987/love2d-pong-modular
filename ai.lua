local AI = {}


function AI.basic(ball, paddle)
    local vdir, hdir = 0, 0
    local cy = paddle.y + paddle.height / 2
    local cx = paddle.x + paddle.width / 2
    
    if ball.dx > 0 and ball.x > WINDOW_WIDTH / 2 then
        if ball.y < cy - 4 then vdir = -1 elseif ball.y > cy + 4 then vdir = 1 end
        if ball.x < cx - 4 then hdir = -1 elseif ball.x > cx + 4 then hdir = 1 end
    end
    return vdir, hdir
end

return AI


  
