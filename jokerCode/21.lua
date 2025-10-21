local me = {}
function me.onJoker()
    if #card.play<4 then
    mult = mult + 20
    return {str="+20 Mult",id=2}
    end
end
return me