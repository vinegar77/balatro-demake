local card= {hand={},handcan={},hselect={},deck={},fdeck={},play={},playcan={},sortMode=true}

--initialize card graphics
card.cardfronts=love.graphics.newImage("resources/textures/cardfronts.png")
card.cardmids=love.graphics.newImage("resources/textures/cardmids.png")
local cardfqs = {}
local cardmqs = {}
for i=1,4 do
    for j=1,13 do
        cardfqs[i.."."..j]=love.graphics.newQuad(j*39-39,i*53-53,39,53,card.cardfronts)
    end
end
for i=0,11 do
    cardmqs[i]=love.graphics.newQuad(math.fmod(i*41,246),i<6 and 0 or 55,41,55,card.cardmids)
end
cardmqs[12]=love.graphics.newQuad(0,110,41,55,card.cardmids)
card.cardfqs=cardfqs
card.cardmqs=cardmqs
local foil = editDraw[1]
local holo = editDraw[2]
local tempfront = love.image.newImageData("resources/textures/cardfronts.png")
local tempmid = love.image.newImageData("resources/textures/cardmids.png")


--Creates a full basic new deck
function card.newBasicDeck()
    local polyimage = polyimage
    local h2rbg = h2rbg
    local polyify = polyify
    for i=1,4 do
        for j=1,13 do
            table.insert(card.fdeck,{rank=j,suite=i,mod=0,seal=0,edit=0,bounce=0})
            table.insert(card.deck,card.fdeck[#card.fdeck])
        end
    end
end

function card.newEnhancedDeck()
    local h2rbg = h2rbg
    local polyify = polyify
    for i=1,4 do
        for j=1,13 do
            table.insert(card.fdeck,{rank=j,suite=i,mod=love.math.random(0,8),seal=love.math.random(0,4),edit=math.random()>.3 and 0 or math.random(1,3),bounce=0})
            --table.insert(card.fdeck,{rank=j,suite=2*love.math.random(1,2),mod=love.math.random(0,8),seal=0,edit=3,bounce=0})
            table.insert(card.deck,card.fdeck[#card.fdeck])
        end
    end
end

local function doPolychrome()
    card.handcan[#card.hand]=love.graphics.newCanvas(41,55)
    love.graphics.setCanvas(card.handcan[#card.hand])
    local ccard = card.hand[#card.hand]
    local tempmidNew = love.image.newImageData(39,53)
    tempmidNew:paste(tempmid,0,0,math.fmod(ccard.mod*41,246)+1,ccard.mod<6 and 1 or 56,39,53)
    hueshift=1.3
    tempmidNew:mapPixel(polyify)
    local tempA = love.graphics.newImage(tempmidNew)
    love.graphics.draw(tempA,1,1)
    tempmidNew,tempA = nil,nil
    if ccard.mod~=1 then
    hueshift=.65
    local tempfrontNew = love.image.newImageData(39,53)
    tempfrontNew:paste(tempfront,0,0,39*(ccard.rank-1),53*(ccard.suite-1),39,53)
    tempfrontNew:mapPixel(polyify)
    local tempB = love.graphics.newImage(tempfrontNew)
    love.graphics.draw(tempB,1,1)
    end
    hueshift=0
end



function card.drawCard(num)
    num=num or 1
    for i=1,num do
        if #card.deck==0 then break end
        local temp=love.math.random(1,#card.deck)
        local drewCard = card.deck[temp]
        drewCard.selected=false
        table.insert(card.hand,drewCard)
        table.remove(card.deck,temp)
        if drewCard.edit==3 then
            doPolychrome()
        else
        card.handcan[#card.hand]=love.graphics.newCanvas(41,55)
        love.graphics.setCanvas(card.handcan[#card.handcan])
        love.graphics.draw(card.cardmids,card.cardmqs[drewCard.mod])
        if drewCard.mod ~= 1 then
            love.graphics.draw(card.cardfronts,card.cardfqs[drewCard.suite.."."..drewCard.rank],1,1)
        end
        if drewCard.edit~=0 then
            love.graphics.setCanvas()
            local tempC = love.graphics.newCanvas(41,55)
            love.graphics.setCanvas(tempC)
            love.graphics.draw(card.handcan[#card.handcan])
            if drewCard.edit==1 then
                love.graphics.setBlendMode("screen","premultiplied")
                love.graphics.draw(foil[1],1,1)
                love.graphics.setBlendMode("alpha")
                love.graphics.setColor(1,1,1,.6)
                love.graphics.draw(foil[2],1,1)
                love.graphics.setColor(1,1,1,1)
            else
                love.graphics.setBlendMode("multiply","premultiplied")
                love.graphics.draw(holo[1],1,1)
                love.graphics.setBlendMode("screen","premultiplied")
                love.graphics.draw(holo[2],1,1)
            end
            love.graphics.setBlendMode("replace","premultiplied")
            love.graphics.setColorMask(false,false,false,true)
            love.graphics.draw(card.cardmids,card.cardmqs[drewCard.mod])
            love.graphics.setBlendMode("alpha")
            if drewCard.mod ~= 1 then
                love.graphics.draw(card.cardfronts,card.cardfqs[drewCard.suite.."."..drewCard.rank],1,1)
            end
            love.graphics.setColorMask()
            love.graphics.setCanvas()
            love.graphics.setCanvas(card.handcan[#card.handcan])
            love.graphics.draw(tempC)
        end
        end
        if drewCard.seal~=0 then
            love.graphics.draw(card.cardmids,card.cardmqs[drewCard.seal+8])
        end
        love.graphics.setCanvas()
    end
end

function card.discardS(hSize)
    local tempaddresses={}
    for k,_ in pairs(card.hselect) do
        table.insert(tempaddresses,k)
    end
    table.sort(tempaddresses)
    for i=#tempaddresses,1,-1 do
        table.remove(card.hand,tempaddresses[i])
        table.remove(card.handcan,tempaddresses[i])
    end
    card.hselect={}
    return card.drawCard(hSize-#card.hand)
end




function card.getSuiteHand(id)
    local ccard=card.hand[id]
    if ccard.mod==1 then
        return -4
    end
    if ccard.mod==2 then
        return -3
    end
    if Smeared then
        return -math.fmod(ccard.suite,2)
    end
    return ccard.suite
end

function card.getSuite(v)
    if v.mod==1 then
        return -4
    end
    if v.mod==2 then
        return -3
    end
    if Smeared then
        return -math.fmod(v.suite,2)
    end
    return v.suite
end


function card.getRankHand(id)
    local ccard=card.hand[id]
    return ccard.mod==1 and 99 or ccard.rank==1 and 14 or ccard.rank
end

function card.getRank(v)
    return v.mod==1 and 99 or v.rank==1 and 14 or v.rank
end

function card.debugHand()
    card.hand={{rank=9,suite=2,mod=0,seal=0,edit=1,selected=false},
{rank=8,suite=3,mod=0,seal=0,edit=0,selected=false},
{rank=7,suite=4,mod=0,seal=0,edit=0,selected=false},
{rank=7,suite=1,mod=0,seal=0,edit=0,selected=false},
{rank=6,suite=4,mod=0,seal=0,edit=0,selected=false},
{rank=4,suite=1,mod=0,seal=0,edit=0,selected=false},
{rank=4,suite=3,mod=0,seal=0,edit=0,selected=false},
{rank=2,suite=2,mod=0,seal=0,edit=0,selected=false}}
for i,v in ipairs(card.hand) do
    card.handcan[i]=love.graphics.newCanvas(41,55)
    love.graphics.setCanvas(card.handcan[i])
    love.graphics.draw(card.cardmids,card.cardmqs[v.mod])
    if v.mod ~= 1 then
        love.graphics.draw(card.cardfronts,card.cardfqs[v.suite.."."..v.rank],1,1)
    end
    love.graphics.setCanvas()
end
end

local function sortbyRank()
    local done=false
    while not done do
    done=true
    for i=2,#card.hand do
    local p,q = math.fmod(card.getRankHand(i-1),99),math.fmod(card.getRankHand(i),99)
    local swap = p==q and card.hand[i-1].suite>card.hand[i].suite or p<q
    if swap then
        card.hand[i-1],card.handcan[i-1],card.hand[i],card.handcan[i]=card.hand[i],card.handcan[i],card.hand[i-1],card.handcan[i-1]
        done=false
    end
    end
    end
end
local function sortbySuite()
    local done=false
    while not done do
    done=true
    for i=2,#card.hand do
    local p,q = card.hand[i-1],card.hand[i]
    p,q = (p.mod==1 and 10 or p.suite),(q.mod==1 and 10 or q.suite)
    local swap = p==q and card.getRankHand(i-1)<card.getRankHand(i) or p>q
    if swap then
        card.hand[i-1],card.handcan[i-1],card.hand[i],card.handcan[i]=card.hand[i],card.handcan[i],card.hand[i-1],card.handcan[i-1]
        done=false
    end
    end
    end
end

function card.sortHand()
    if card.sortMode then
        return sortbyRank()
    end
    return sortbySuite()
end

return card