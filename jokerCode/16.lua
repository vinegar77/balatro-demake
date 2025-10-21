local me = {}
function me.onBuy()
    me.myjslotid=#joker.jslots
end
function me.onScore(_,suite)
    if suite==2 or suite==0 or suite==-3 then
    mult = mult + 3
    return {str="+3 Mult",id=2,key=me.myjslotid,drawLoc=3}
    end
end
return me