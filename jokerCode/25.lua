local me = {}
me.noCopy=true

function me.onBuy()
    maxdiscards=maxdiscards+1
    cdiscards=cdiscards+1
end

return me