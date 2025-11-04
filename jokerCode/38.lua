local me = {}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onScoreRe(rank)
    if rank>10 and rank<14 then
        return {key=me.myjslotid}
    end
end

return me