local me = {}
function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onDiscard()
local numFace=0
for _,v in pairs(card.hselect) do
    if v.rank~=14 and v.rank>10 then
        numFace=numFace+1
    end
end
if numFace>2 then
    money=money+3
    return {str="+$3",id=3,key=me.myjslotid,drawLoc=3}
end
end

return me