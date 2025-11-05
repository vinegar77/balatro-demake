local me = {}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onHandRe()
    return {key=me.myjslotid}
end

return me