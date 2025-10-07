local me = {myjslotid=0}
function me.onBuy()
    me.myjslotid=#joker.jslots
end
function me.onScore(rank)
    if rank<11 and math.fmod(rank,2)==0 then
    mult = mult + 4
    return {str="+4 Mult",id=2,key=me.myjslotid,drawLoc=3}
    end
end
return me