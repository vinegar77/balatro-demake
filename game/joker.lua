local joker={init=nil,jslots={},jcan={},jspace=0,joffset=0}
local card, Updater, Drawer
joker.jokerAtlas = love.graphics.newImage("resources/textures/jokers.png")
local scoreCardStages = scoreCardStages
local scoreCardReStages = scoreCardReStages

function joker.init(c,u,d)
    card=c
    Updater = u
    Drawer = d
end

function joker.addNewJoker(id,edit)
    local newJoker = require("jokerCode/"..id)
    package.loaded["jokerCode/"..id]=nil
    joker.jslots[#joker.jslots+1] = newJoker
    local temp1 = love.graphics.newCanvas(39,53)
    local temp2 = love.graphics.newQuad(1+41*math.fmod(id-1,10),1+55*math.floor((id-1)/10),39,53,joker.jokerAtlas)
    if edit and edit~=0 then
        joker.drawModJoker(id,edit,temp1,temp2)
    else
        love.graphics.setCanvas(temp1)
        love.graphics.draw(joker.jokerAtlas,temp2)
        love.graphics.setCanvas()
    end
    local j = #joker.jslots
    joker.jcan[j]=temp1
    if newJoker.onBuy then newJoker.onBuy() end
    joker.addStages(newJoker)
    joker.jspace=(j<4 and 100 or math.floor(200/(j-1)))
    joker.joffset=(j>2 and 4 or j==2 and 54 or j==1 and 104)
end
function joker.addStages(cjoker)
    if cjoker.onScore then
        table.insert(scoreCardStages[1],cjoker.onScore)
    end
    if cjoker.onHand then
        table.insert(scoreCardStages[2],cjoker.onHand)
    end
    if cjoker.onJoker then
        --scoreCardStages[3][#scoreCardStages[3]+1]=cjoker.onJoker
        table.insert(scoreCardStages[3],cjoker.onJoker)
    else
        table.insert(scoreCardStages[3],false)
    end
end


return joker