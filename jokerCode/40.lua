local me = {}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onHand(rank)
    if rank==13 then
        mult=mult*1.5
        local temp = 10^(3-math.min(math.floor(math.log10(mult)),3))
        mult=math.floor(temp*mult)/temp
        return {str="X1.5 Mult",id=4,jumper=joker.jslots[me.myjslotid]}
    end
end

return me