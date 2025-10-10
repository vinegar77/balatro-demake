local me = {}
local cmult = 0
local myjslotid

function me.onBuy()
    myjslotid=#joker.jslots
end

function me.onPlayEffect()
    cmult=cmult+1
    return {str="+1 Mult",id=3,key=myjslotid,drawLoc=3}
end

function me.onDiscard()
    if cmult~=0 then
    cmult=cmult-1
    return {str="-1 Mult",id=2,key=myjslotid,drawLoc=3}
    end
end

function me.onJoker()
    if cmult~=0 then
    mult = mult + cmult
    return {str="+"..cmult.." Mult",id=2}
    end
end
return me