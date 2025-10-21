local me = {}
function me.onBuy()
    me.myjslotid=#joker.jslots
end
function me.onScore(rank)
    if rank==14 or rank<10 and math.fmod(rank,2)==1 then
    chips = chips + 31
    return {str="+31",id=1,key=me.myjslotid,drawLoc=3}
    end
end
return me