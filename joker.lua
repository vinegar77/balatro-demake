local joker={init=nil,jslots={},jcan={},jspace=0,joffset=0}
local card, Updater, Drawer
joker.jokerAtlas = love.graphics.newImage("resources/textures/jokers.png")
local jokeImData = love.image.newImageData("resources/textures/jokers.png")
joker.maxjslots = 5
local scoreCardStagesl = scoreCardStages
local scoreCardReStagesl = scoreCardReStages
local playEffectStagesl = playEffectStages
local tempP = love.graphics.newCanvas(39,53)
local tempA = love.image.newImageData(39,53)

function joker.init(c,u,d)
    card=c
    Updater = u
    Drawer = d
end

local scoreStagesDefault={}

function joker.setDefaultStagesLoad()
    for i=1,2 do
        scoreStagesDefault[i]={}
        for j,v in ipairs(scoreCardStagesl[i]) do
            scoreStagesDefault[i][j]=v
        end
    end
    scoreStagesDefault[3]={}
    for i=1,2 do
        scoreStagesDefault[i+3]={}
        for j,v in ipairs(scoreCardReStagesl[i]) do
            scoreStagesDefault[i+3][j]=v
        end
    end
end

function joker.returnDefaultStages()
    local temp,tempRe = {{},{},{}},{{},{}}
    for i=1,2 do
        for j,v in ipairs(scoreStagesDefault[i]) do
            temp[i][j]=v
        end
    end
    for i=1,2 do
        for j,v in ipairs(scoreStagesDefault[i+3]) do
            tempRe[i][j]=v
        end
    end
    return temp, tempRe
end


local foil=editDraw[1]
local holo = editDraw[2]
local polyimage=editDraw[3]
local hueshift=0
--global psuedo shaders

local function negate(_,_,r,g,b,a)
    return 1.05-.88*b, 1.28-g, 1.3-.978*r, a
end

local function h2rbg(p,q,h)
    h = math.fmod(h,1)*6
    return h<1 and p+(q-p)*h or h<3 and q or h<4 and p+(q-p)*(4-h) or p
end

local function polyify(x,y,r,g,b,a)
    local lo,hi = math.min(r,g,b),math.max(r,g,b)
    local d = hi-lo
    if (d==0) then return r,g,b,a end
    local sum = hi+lo
    local h,s,l = 0,0,.5*sum
    local sog = sum<1 and d/(sum) or d/(2-sum)
    local hog = (hi==r and (g-b)/d + (g<b and 6 or 0) or hi==g and (b-r)/d+2 or (r-g)/d + 4)/6
    r, g, b = polyimage:getPixel(x,y)
    lo, hi = math.min(r,g,b),math.max(r,g,b)
    d = hi-lo
    sum = hi+lo
    s = sum<1 and d/sum or d/(2-sum)
    s = (s+sog)/2
    if s<.0001 then return l,l,l,a end
    h = (hi==r and (g-b)/d + (g<b and 6 or 0) or hi==g and (b-r)/d+2 or (r-g)/d + 4)/6
    h = h+.3*s*hog+hueshift
    l = l - (l<.45 and .08 or 0)
    local q = l<.5 and l*(.9+s) or l+s-l*s
    local p = 2*l-q
    return h2rbg(p,q,h+1/3),h2rbg(p,q,h),h2rbg(p,q,h-1/3),a
end

function joker.drawModJoker(id,edit,temp1,temp2)
    if edit==1 then
        love.graphics.setCanvas(tempP)
        love.graphics.setBlendMode("replace")
        love.graphics.setColor(1,1,1,0)
        love.graphics.rectangle("fill",0,0,39,53)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1,1,1,1)

        love.graphics.draw(joker.jokerAtlas,temp2)
        love.graphics.setBlendMode("screen")
        love.graphics.draw(foil[1])
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1,1,1,.8)
        love.graphics.draw(foil[2])
        love.graphics.setColor(1,1,1,1)
        love.graphics.setBlendMode("replace")
        love.graphics.setColorMask(false,false,false,true)
        love.graphics.draw(joker.jokerAtlas,temp2)
        love.graphics.setColorMask()
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
        love.graphics.setCanvas(temp1)
        love.graphics.draw(tempP)
        love.graphics.setCanvas()
        return
    end
    if edit==2 then
        love.graphics.setCanvas(tempP)
        love.graphics.setBlendMode("replace")
        love.graphics.setColor(1,1,1,0)
        love.graphics.rectangle("fill",0,0,39,53)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1,1,1,1)

        love.graphics.draw(joker.jokerAtlas,temp2)
        love.graphics.setBlendMode("multiply","premultiplied")
        love.graphics.draw(holo[1])
        love.graphics.setBlendMode("screen","premultiplied")
        love.graphics.draw(holo[2])
        love.graphics.setBlendMode("alpha","alphamultiply")
        love.graphics.setBlendMode("replace")
        love.graphics.setColorMask(false,false,false,true)
        love.graphics.draw(joker.jokerAtlas,temp2)
        love.graphics.setColorMask()
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
        love.graphics.setCanvas(temp1)
        love.graphics.draw(tempP)
        return love.graphics.setCanvas()
    end
    if edit==3 then
        tempA:paste(jokeImData,0,0,1+41*math.fmod(id-1,10),1+55*math.floor((id-1)/10),39,53)
        hueshift=love.math.random()
        tempA:mapPixel(polyify)
        hueshift=0
        local tempC = love.graphics.newImage(tempA)
        love.graphics.setCanvas(temp1)
        love.graphics.draw(tempC)
        return love.graphics.setCanvas()
    end
    tempA:paste(jokeImData,0,0,1+41*math.fmod(id-1,10),1+55*math.floor((id-1)/10),39,53)
    tempA:mapPixel(negate)
    local tempC = love.graphics.newImage(tempA)
    love.graphics.setCanvas(temp1)
    love.graphics.draw(tempC)
    return love.graphics.setCanvas()
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
    newJoker.bounce=0
    newJoker.edit = edit
    if edit == -1 then
        joker.maxjslots = joker.maxjslots+1
    end
    joker.addStages(newJoker)
    joker.jspace=(j<4 and 100 or math.floor(200/(j-1)))
    joker.joffset=(j>2 and 4 or j==2 and 54 or j==1 and 104)
    for _,v in ipairs(joker.jslots) do
        if v.shiftUpdate then v.shiftUpdate() end
    end
end
function joker.addStages(cjoker)
    if cjoker.onPlayEffect then
        table.insert(playEffectStagesl,cjoker.onPlayEffect)
    end
    if cjoker.onScore then
        table.insert(scoreCardStagesl[1],cjoker.onScore)
    end
    if cjoker.onHand then
        table.insert(scoreCardStagesl[2],cjoker.onHand)
    end
    if cjoker.edit then
        if cjoker.edit==1 then
            table.insert(scoreCardStagesl[3],foilScore)
        end
        if cjoker.edit==2 then
            table.insert(scoreCardStagesl[3],holoScore)
        end
    end
    if cjoker.onJoker then
        --scoreCardStages[3][#scoreCardStages[3]+1]=cjoker.onJoker
        table.insert(scoreCardStagesl[3],cjoker.onJoker)
    else
        table.insert(scoreCardStagesl[3],false)
    end
    if cjoker.edit==3 then
        table.insert(scoreCardStagesl[3],polyScore)
    end
    if cjoker.onDiscard then
        table.insert(preDiscardStages,cjoker.onDiscard)
    end
end

function joker.postDrag()
    scoreCardStages,scoreCardReStages = joker.returnDefaultStages()
    scoreCardStagesl,scoreCardReStagesl = scoreCardStages,scoreCardReStages
    preDiscardStages={}
    playEffectStages = {}
    playEffectStagesl=playEffectStages
    for i,v in ipairs(joker.jslots) do
        if v.myjslotid then v.myjslotid = i end
        if v.shiftUpdate then v.shiftUpdate() end
        joker.addStages(v)
    end
end


return joker