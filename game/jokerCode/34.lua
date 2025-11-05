local me = {}
local cmult = 0
me.copyIndx={"onJoker"}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onPlayEffect()
    local hasFace = false
    for _,v in ipairs(card.toScore) do
        local temp = card.getRank(v)
        if temp>10 and temp<14 then hasFace=true break end
    end
    if hasFace then
        if cmult==0 then return end
        cmult=0
        return {str="Reset!",id=2,key=me.myjslotid,drawLoc=3}
    end
    cmult=cmult+1
    return {str="+1 Mult",id=3,key=me.myjslotid,drawLoc=3}
end

function me.onJoker()
    if cmult~=0 then
    mult = mult + cmult
    return {str="+"..cmult.." Mult",id=2}
    end
end
return me