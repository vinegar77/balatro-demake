local me = {}
local stonerchips = 0
function me.onBuy()
    for _,v in ipairs(card.fdeck) do
        if v.mod==1 then
        stonerchips = stonerchips + 25
        end
    end
end

-- TO ADD WITH CONSUMABLES:
-- Update stonerchips by # stone in full deck!

function me.onJoker()
    chips=chips+stonerchips
    return {str="+"..stonerchips,id=1}
end
return me