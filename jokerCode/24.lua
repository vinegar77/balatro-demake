local me = {}

function me.onBuy()
    handSize=handSize+1
    updateHSizeVars(handSize)
end

return me