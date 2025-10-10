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
card.cardfqs=cardfqs
card.cardmqs=cardmqs

--Creates a full basic new deck
function card.newBasicDeck()
    for i=1,4 do
        for j=1,13 do
            table.insert(card.fdeck,{rank=j,suite=i,mod=0,seal=0,edit=0})
            table.insert(card.deck,{rank=j,suite=i,mod=0,seal=0,edit=0})
        end
    end
end

function card.newEnhancedDeck()
    for i=1,4 do
        for j=1,13 do
            table.insert(card.fdeck,{rank=j,suite=i,mod=love.math.random(0,8),seal=0,edit=0})
            --table.insert(card.fdeck,{rank=j,suite=i,mod=6,seal=4,edit=0})
            table.insert(card.deck,card.fdeck[#card.fdeck])
        end
    end
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
        card.handcan[#card.hand]=love.graphics.newCanvas(41,55)
        love.graphics.setCanvas(card.handcan[#card.handcan])
        love.graphics.draw(card.cardmids,card.cardmqs[drewCard.mod])
        if drewCard.mod ~= 1 then
            love.graphics.draw(card.cardfronts,card.cardfqs[drewCard.suite.."."..drewCard.rank],1,1)
        end
        if drewCard.edition~=0 then
            
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
        return -1
    end
    if ccard.mod==2 then
        return -3
    end
    if Smeared then
        return math.fmod(ccard.suite,2)
    end
    return ccard.suite
end

function card.getSuite(v)
    if v.mod==1 then
        return -1
    end
    if v.mod==2 then
        return -3
    end
    if Smeared then
        return math.fmod(v.suite,2)
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