local me = {}
local weewee = 0
me.copyIndx = {"onJoker"}
function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onScore(rank)
    if rank==2 then
        weewee = weewee + 8
        return {str="Upgrade!",id=3,key=me.myjslotid,drawLoc=3}
    end
end

function me.onJoker()
    if weewee>0 then
    chips=chips+weewee
    return {str="+"..weewee,id=1}
    end
end
return me