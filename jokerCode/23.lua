local me = {}
local cchips = 0
me.copyIndx={"onJoker"}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onPlayEffect()
    if #card.play==4 then
        cchips=cchips+4
        return {str="Upgrade!",id=1,key=me.myjslotid,drawLoc=3}
    end
end

function me.onJoker()
    if cchips~=0 then
    chips = chips + cchips
    return {str="+"..cchips,id=1}
    end
end
return me