local me = {}
local numScoring
local firstScore = true
me.copyIndx={"onScoreRe"}

function me.onBuy()
    me.myjslotid=#joker.jslots
end

function me.onPlayEffect()
    numScoring=#card.toScore
end

function me.onScoreRe()
    if numScoring==#card.toScore then
        if firstScore then
            ccardReStage=ccardReStage-1
            firstScore=false
        else
            firstScore=true
        end
        return {key=me.myjslotid}
    end
end

return me