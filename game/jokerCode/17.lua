local me = {}
function me.onBuy()
    me.myjslotid=#joker.jslots
end
function me.onScore(_,suite)
    if suite==1 or suite==-1 then
    mult = mult + 3
    return {str="+3 Mult",id=2,key=me.myjslotid,drawLoc=3}
    end
end
return me