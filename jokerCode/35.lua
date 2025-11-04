local me = {}
local steelmultrun = 1
function me.onBuy()
    for _,v in ipairs(card.fdeck) do
        if v.mod==7 then
        steelmultrun = steelmultrun + .2
        end
    end
end

-- TO ADD WITH CONSUMABLES:
-- Update stonerchips by # stone in full deck!

function me.onJoker()
    --need to add a dedicated multiplying function at some point
    mult=mult*steelmultrun
    local temp = 10^(3-math.min(math.floor(math.log10(mult)),3))
    mult=math.floor(temp*mult)/temp
    return {str="X"..steelmultrun.." Mult",id=4}
end
return me