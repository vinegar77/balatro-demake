local me = {}
function me.onJoker()
    local temp = love.math.random(0,23)
    mult = mult + temp
    return {str="+"..temp.." Mult",id=2}
end
return me