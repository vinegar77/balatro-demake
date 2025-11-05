local me = {isStencil = true}
local xmult
function me.shiftUpdate()
    local usedjslots = 0
    for _,v in ipairs(joker.jslots) do
        usedjslots = usedjslots + (v.isStencil and 0 or 1)
    end
    --replace with numjslots
    xmult = joker.maxjslots-usedjslots
end

function me.onJoker()
    mult=mult*math.max(1,xmult)
    return {str="X"..xmult.." Mult",id=4}
end
return me