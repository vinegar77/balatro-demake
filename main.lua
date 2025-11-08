---[[
    require"nest".init({console="3ds",scale=2})
if arg[2] == "debug" then
    require("lldebugger").start()
end
--]]
local cursorid,cursor,nselect,scoreIds,animationflag,score,ui,uicanvas
local dischips,dismult,chiprate,multrate,spamdelay, cante, blindcan, blindrq, dispscore, imult, ichips, scoringPopup, cDist, cOffset, dragMode, cursorD
local updateBlind, bigFont, writeBig, dispscoreS, noUpMult, jSlotShad, nScoringEvents, uiButts, aHeldTimer, bUICan
local font18,fonttiny, scoreTimer, prescore, playCardStartPos, nhcard, shand, njoker, sjoke, demobgmusic, triggersfx, scoreupsfx, selectsfx, deselectsfx, dragsfx
local Updater,Drawer,bigFontq,priorityDrawer={},{},{},{}
local drawToUiCanvas, calcAddScore, drawHandCards, drawJokers, topScreenDraw, updateBUiCan 
card,hTypes,fourfinger,shortcut,curHand,chips,mult,money,chands,cdiscards,maxhands,maxdiscards,handSize,joker=nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
scoreCardStages,scoreCardReStages,playEffectStages,preDiscardStages = {},{},{},{}
local scoreCardScoringStages,scoreCardHandStages,scoreCardScoringReStages,scoreCardHandReStages

local function loadScreenDraw(screen,_)
    if screen=="bottom" then
        love.graphics.print("Loading...",20,20)
    end
end

local card, scoreCardStages, scoreCardReStages, playEffectStages,joker,jumpMap
local loadCoro = coroutine.create(function ()
    coroutine.yield()
    editDraw = {{love.graphics.newImage("resources/textures/editions/foilb.png"),love.graphics.newImage("resources/textures/editions/foilt.png")},
    {love.graphics.newImage("resources/textures/editions/holob.png"), love.graphics.newImage("resources/textures/editions/holot.png")},
    love.image.newImageData("resources/textures/editions/poly.png")}
    scoreCardStages=_G.scoreCardStages
    scoreCardReStages = _G.scoreCardReStages
    playEffectStages = _G.playEffectStages
    coroutine.yield()
    _G.card=require "card"
    _G.joker=require "joker"
    card = _G.card
    _G.joker.init(card,Updater,Drawer)
    joker = _G.joker
    jumpMap = {card.play,card.hand,joker.jslots}
    coroutine.yield()
    scoreCardStages[1]=scoreCardScoringStages
    scoreCardStages[2]=scoreCardHandStages
    scoreCardStages[3]={}
    scoreCardReStages[1]=scoreCardScoringReStages
    scoreCardReStages[2]=scoreCardHandReStages
    bigFont=love.graphics.newImage("resources/textures/testimfont.png")
    fonttiny=love.graphics.newFont("resources/m6x11plus.ttf",11)
    cursor=love.graphics.newImage("resources/textures/cursor.png")
    cursorD=love.graphics.newImage("resources/textures/cursor2.png")
    uiButts = love.graphics.newImage("resources/textures/uibuttons.png")
    jSlotShad=love.graphics.newImage("resources/textures/jokerSlotShadow.png")
    ui=love.graphics.newImage("resources/textures/uithing.png")
    scoringPopup={love.graphics.newImage("resources/textures/popup/chips.png"),
    love.graphics.newImage("resources/textures/popup/mult.png"),
    love.graphics.newImage("resources/textures/popup/cash.png"),
    love.graphics.newImage("resources/textures/popup/mult.png"),
    love.graphics.newImage("resources/textures/popup/mult.png")}
    coroutine.yield()
    demobgmusic=love.audio.newSource("resources/tbnewloop_unrolledBalatro.ogg","stream")
    demobgmusic:setLooping(true)
    triggersfx=love.audio.newSource("resources/trigger.ogg","static")
    scoreupsfx=love.audio.newSource("resources/scoreaddreal.wav","stream")
    selectsfx=love.audio.newSource("resources/select.wav","static")
    deselectsfx=love.audio.newSource("resources/deselect.wav","static")
    dragsfx=love.audio.newSource("resources/drag.wav","static")
    scoreupsfx:setLooping(true)
    coroutine.yield()
    uicanvas=love.graphics.newCanvas(153,240)
    blindcan=love.graphics.newCanvas(135,71)
    bUICan=love.graphics.newCanvas(320,240)
    local bigfntatlas={"1","2","3","4","5","6","7","8","9","0",",","$","-"}
    local x=0
    for _,v in ipairs(bigfntatlas) do
        bigFontq[v]=love.graphics.newQuad(x,0,(v=="," and 6 or 14),24,bigFont)
        x=x+(v=="," and 6 or 14)
    end
    coroutine.yield()
    card.newEnhancedDeck()
    joker.setDefaultStagesLoad()
    joker.demoRandJoker()
    joker.demoRandJoker()
    joker.demoRandJoker()
    coroutine.yield()
    joker.demoRandJoker()
    joker.demoRandJoker()
    joker.demoBonusNeg()
    scoreCardStages= _G.scoreCardStages
    scoreCardReStages = _G.scoreCardReStages
    playEffectStages = _G.playEffectStages
    coroutine.yield()
    card.drawCard(handSize)
    card.sortHand()
    coroutine.yield()
    updateBlind(1)
    updateBUiCan()
    table.remove(Drawer,1)
    love.graphics.setBackgroundColor(.231,.467,.369)
    table.insert(priorityDrawer,topScreenDraw)
    table.insert(priorityDrawer,drawJokers)
    table.insert(priorityDrawer,drawHandCards)
    table.insert(Drawer,drawToUiCanvas)
    demobgmusic:play()
    animationflag=false
end)

local function loadCoroManager(_,myid)
    if not coroutine.resume(loadCoro) then
        table.remove(Updater,myid)
    end
end


function love.load()
    animationflag=true
    if love.graphics.setStereoscopic then
    love.graphics.setStereoscopic(false)
    end
    love.graphics.setDefaultFilter("nearest","nearest")
    font18 = love.graphics.newFont("resources/m6x11plus.ttf",18)
    love.graphics.setFont(font18)
    chips,dischips=0,0
    mult,dismult=0,0
    spamdelay=0
    money=0
    dragMode=false
    cante,blindrq=1,3590 --update with function to determine later
    score,dispscore,dispscoreS=0,0,"0"
    handSize=8
    updateHSizeVars(handSize)
    maxhands=4
    maxdiscards=3
    chands=maxhands
    cdiscards=maxdiscards
    Smeared=false
    cursorid={1,1}
    nselect=0
    score=0
    fourfinger=false
    shortcut=false
    nScoringEvents=0
    table.insert(Updater,loadCoroManager)
    love.graphics.setBackgroundColor(0.31,0.38,0.40,1)
    table.insert(Drawer,loadScreenDraw)
end

--massive.....
local function idHandTypes()
    local sortedS = {}
    local sortedSids={}
    local handTypeContained = {}
    local scoreIds = {}
    local temp = {}
    handTypeContained[12]=true
    for k,_ in pairs(card.hselect) do
        table.insert(temp,{card.getRankHand(k),k})
    end
    if #temp==1 then return {handTypeContained,12,{temp[1][2]}} end
    table.sort(temp,function (a, b)
        return a[1]<b[1]
    end)
    for i,v in ipairs(temp) do
        sortedS[i]=v[1]
        sortedSids[i]=v[2]
    end
    local last = -999
    local streak = 0
    local streakid={}
    local laststreak
    local laststreakid={}
    for i,v in ipairs(sortedS) do
        if v==99 then
            table.insert(scoreIds,sortedSids[i])
        elseif v==last then
            table.insert(streakid,sortedSids[i])
            if streak==0 then table.insert(streakid,sortedSids[i-1]) end
            streak=streak+1
        elseif streak>0 then
            if laststreak then break end
            laststreakid=streakid
            laststreak=streak
            streak=0
            streakid={}
            last=v
        else
            last=v
        end
    end
    -- check for full house or 2 pair
    if laststreak and streak>0 then
        handTypeContained[11]=true
        handTypeContained[10]=true
        --check for full house
        if streak+laststreak==3 then
            handTypeContained[9]=true
            handTypeContained[6]=true
        end
        for _,v in ipairs(streakid) do
        table.insert(scoreIds,v)
        end
        for _,v in ipairs(laststreakid) do
        table.insert(scoreIds,v)
        end
    else
        --pair/_oak check
        streak= streak==0 and laststreak or streak
        streakid = streakid[1] and streakid or laststreakid
        if streak>0 then
            handTypeContained[11]=true
            if streak>1 then
                handTypeContained[9]=true
                if streak>2 then
                    handTypeContained[5]=true
                    if streak>3 then
                        handTypeContained[3]=true
                    end
                end
            end
            for _,v in ipairs(scoreIds) do 
                table.insert(streakid,v)
            end
            scoreIds=streakid
        end
    end
    -- Straight Check
    local isStraight
    local nonscoreid
    if not handTypeContained[3] and #sortedS>(fourfinger and 3 or 4) then
        isStraight=true
        local last = sortedS[1]
        local fourfingersave=fourfinger and nselect==5
        for i=2,#sortedS do
            if card.hselect[sortedSids[i]].mod==1 then
                if fourfingersave then
                    fourfingersave=false
                else
                    isStraight=false
                    break
                end
            elseif sortedS[i]-last ~= 1 and (not shortcut or sortedS[i]-last ~= 2) then
                if fourfingersave then
                    if i==2 or i==5 or sortedS[i]-last==0 then
                        fourfingersave=false
                        if sortedS[i]-last~=0 then
                        nonscoreid=(i==5 and 5 or i-1)
                        last=sortedS[i]
                        end
                    else
                        isStraight=false
                        break
                    end
                else
                    isStraight=false
                    break
                end
            else
            last=sortedS[i]
            end
        end
        if fourfinger and isStraight and sortedS[#sortedS]==14 and (sortedS[1]==2 or shortcut and sortedS[1]==3) then
            nonscoreid=nil
        end
        if not isStraight and (sortedS[#sortedS]==14 or fourfinger and sortedS[#sortedS-1]==14) then
            isStraight=true
            local last= 1
            local fourfingersave=fourfinger and nselect==5
            nonscoreid=nil
            for i=1, #sortedS-1 do
                if sortedS[i]-last ~= 1 and (not shortcut or sortedS[i]-last ~= 2) then
                    if fourfingersave then
                        fourfingersave=false
                        nonscoreid=(i==4 and 4 or i-1)
                        last=sortedS[i]
                    else
                        isStraight=false
                        break
                    end
                else
                    last=sortedS[i]
                end
            end
            if isStraight and sortedS[#sortedS]==99 then
                nonscoreid=nil
            end
        end
        if isStraight then
            handTypeContained[8]=true
            if not (handTypeContained[3] or handTypeContained[5] or handTypeContained[6]) then
                for i,v in ipairs(sortedSids) do
                    scoreIds[i]=v
                end
                if nonscoreid then
                    table.remove(scoreIds,nonscoreid)
                end
            end
        end
    end
    -- Flush Check
    if #sortedS>(fourfinger and 3 or 4) and sortedS[1]~=99 then
        local last=card.getSuiteHand(sortedSids[1])
        local superTemp=2
        for i=2,#sortedS do
            if last~=-3 then
                break
            end
            last=card.getSuiteHand(sortedSids[i])
            superTemp=i+1
        end
        local fourfingersave =fourfinger and nselect==5
        local nonscoreidf
        local isFlush = true
        for i=superTemp,#sortedSids do
            local ccard= card.getSuiteHand(sortedSids[i])
            if ccard~=-3 and ccard~=last then
                if fourfingersave then
                    fourfingersave=false
                    if i==2 and ccard==card.getSuiteHand(sortedSids[3])then
                        nonscoreidf=1
                        last = ccard
                    elseif ccard~=-4 then
                    nonscoreidf=i
                    end
                else
                    isFlush=false
                    break
                end
            end
        end
        if isFlush then
            handTypeContained[7]=true
            if not (handTypeContained[3] or handTypeContained[6]) then
                if not handTypeContained[5] then
                    scoreIds=sortedSids
                end
                if handTypeContained[8] then
                    scoreIds=sortedSids
                    handTypeContained[4] = true
                    if nonscoreid and nonscoreidf and nonscoreid==nonscoreidf then
                         table.remove(scoreIds,nonscoreid)
                    end
                elseif nonscoreidf then
                    table.remove(scoreIds,nonscoreidf)
                end
            elseif not handTypeContained[3] then
                handTypeContained[2]=true
                scoreIds=sortedSids
            else
                handTypeContained[1]=true
                scoreIds=sortedSids
            end
        end
    end
    local handTypeDigestable = {}
    for k,_ in pairs(handTypeContained) do
        handTypeDigestable[#handTypeDigestable+1]=k
    end
    table.sort(handTypeDigestable)
    --high card
    if handTypeDigestable[1]==12 then
        for i=#sortedS,1,-1 do
            if sortedS[i]~=99 then
                scoreIds[#scoreIds+1]=sortedSids[i]
                break
            end
        end
    end
    return {handTypeContained,handTypeDigestable[1],scoreIds}
end

local HandTypes = {{name="Flush Five",bchips=160,bmult=16,lvl=1},
{name="Flush House",bchips=140,bmult=14,lvl=1},
{name="Five of a Kind",bchips=120,bmult=12,lvl=1},
{name="Straight Flush",bchips=100,bmult=8,lvl=1},
{name="Four of a Kind",bchips=60,bmult=7,lvl=1},
{name="Full House",bchips=40,bmult=4,lvl=1},
{name="Flush",bchips=35,bmult=4,lvl=1},
{name="Straight",bchips=30,bmult=4,lvl=1},
{name="Three of a Kind",bchips=30,bmult=3,lvl=1},
{name="Two Pair",bchips=20,bmult=2,lvl=1},
{name="Pair",bchips=10,bmult=2,lvl=1},
{name="High Card",bchips=5,bmult=1,lvl=1}}

local function formatNum(num,elimit)
    if num<1000 then return num end

    if num>(10^elimit) then
        local t=tostring(num)
        return t:sub(0,1).."."..t:sub(2,(elimit==5 and 2 or 4)).."e"..math.floor(math.log10(num))
    end
    local _,_,neg,absnum = tostring(num):find("([-]?)(%d+)")
    absnum = absnum:reverse():gsub("(%d%d%d)","%1,")
    return neg..absnum:reverse():gsub("^,","")
end

function writeBig(str,x,y,lim,align)
    str=tostring(str)
    if align and align=="center" then
        local _, commanum = str:gsub(",", " ")
        local fullcharnum = str:len()-commanum
        x=math.floor((2*x+lim-fullcharnum*14-commanum*6)/2)
    end
    for i=1,str:len() do
        local c=str:sub(i,i)
        love.graphics.draw(bigFont,bigFontq[c],x,y)
        x = x+ (c=="," and 6 or 14)
    end
end

function drawToUiCanvas(dt,myid)
    love.graphics.setBlendMode("alpha","alphamultiply")
    if not uicanvas then
        return
    end
    love.graphics.setCanvas(uicanvas)
    love.graphics.draw(ui,12,0)
    love.graphics.setColor(.118,.451,.871)
    love.graphics.printf(chands,86,191,10,"center")
    love.graphics.setColor(.937,.227,.227)
    love.graphics.printf(cdiscards,125,191,10,"center")
    love.graphics.setColor(.969,.78,.149)
    writeBig("$"..money,22,192,44,"center")
    love.graphics.setColor(.827,.573,.149)
    love.graphics.printf("Ante "..cante.."/8",83,215,56,"center")
    love.graphics.setColor(.102,.149,.184)
    love.graphics.printf(dischips,35,144,35,"right")
    love.graphics.printf(dismult,95,144,35,"left")
    love.graphics.setColor(1,1,1)
    love.graphics.printf(dischips,34,143,35,"right")
    love.graphics.printf(dismult,94,143,35,"left")
    if (nselect>0) then
        love.graphics.printf(curHand.name,font18,25,121,114,"center")
        love.graphics.printf("lvl "..curHand.lvl,fonttiny,71,136,22,"center")
    end
    love.graphics.printf(dispscoreS,font18,25,93,116,"center")
    love.graphics.setCanvas()
    return myid and table.remove(Drawer,myid)
end

local function updateUiCanvas(dt,myid)
    local dchips = chips-dischips
    local deleteself= dchips==0 and mult==dismult
    table.insert(Drawer,drawToUiCanvas)
    if deleteself then
        chiprate,multrate,imult=nil,nil,0
        return myid and table.remove(Updater,myid)
    end
    if not chiprate then
        if mult>10^5 then
            noUpMult=true
        end
        chiprate=math.ceil(math.abs(dchips)/20)*(dchips>0 and 1 or -1)
        multrate=dchips
        imult=dismult
    end
    dischips=dischips+(dchips/chiprate>1 and chiprate or dchips)
    if noUpMult then
        if dchips==0 then
            chiprate,multrate,imult=nil,nil,0
            return myid and table.remove(Updater,myid)
        end
    return end
    dismult=math.floor((multrate-dchips)/multrate*(mult-imult))+imult
end

local function updateUiCMultOnly(dt,myid)
    local dmult = mult-tonumber(dismult)
    local deleteself= dmult==0
    table.insert(Drawer,drawToUiCanvas)
    if deleteself then
        chiprate,multrate,imult=nil,nil,0
        return myid and table.remove(Updater,myid)
    end
    if not chiprate then
        if mult>10^5 then
            dismult=formatNum(mult,5)
            chiprate,multrate,imult=nil,nil,0
            return myid and table.remove(Updater,myid)
        end
        chiprate=math.ceil(math.abs(dmult)/20)*(dmult>0 and 1 or -1)
    end
    dismult=dismult+(dmult/chiprate>1 and chiprate or dmult)
end

function updateBUiCan()
    love.graphics.setCanvas(bUICan)
    love.graphics.setColor(.231,.467,.369)
    love.graphics.rectangle("fill",0,0,320,240)
    love.graphics.setColor(.793,.835,.915)
    love.graphics.printf(#card.hand.."/"..handSize,fonttiny,145,175,33,"center")
    love.graphics.printf(#joker.jslots.."/"..joker.maxjslots,fonttiny,105,63,39,"center")
    love.graphics.setColor(1,1,1)
    love.graphics.draw(jSlotShad,1,46)
    love.graphics.draw(uiButts,18,188)
    love.graphics.setCanvas()
end

function updateBlind(blindId)
    love.graphics.setCanvas(blindcan)
    love.graphics.draw(love.graphics.newImage("resources/textures/blinds/blind"..blindId..".png"))
    love.graphics.setColor(.937,.227,.227)
    if math.log10(blindrq)<5 then
        writeBig(formatNum(blindrq,10),45,40)
    else
        love.graphics.printf(formatNum(blindrq,10),44,41,89,"left")
    end
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas()
end

local function drawPlayedCards(screen,myid)
    if screen~="bottom" then
        love.graphics.setBlendMode("alpha","premultiplied")
        for i,v in ipairs(card.playcan) do
            love.graphics.draw(v,playCardStartPos+45*i,(not prescore and card.play[i].scoring and 111+card.play[i].bounce or 129))
        end
        love.graphics.setBlendMode("alpha","alphamultiply")
        table.remove(Drawer,myid)
    end
end

function love.chance(denominator)
    return love.math.random(1,denominator)==1
end

ccardStage = 1
ccardReStage=1

scoreCardScoringStages = {
    function (rank,_,mod,_,_,_)
        --stage 1 (always returns nonzero)
        local dchip= (rank==99 and 50 or rank==14 and 11 or rank>9 and 10 or rank)+(mod==3 and 30 or 0)
        chips=chips+dchip
        return {str="+"..dchip,id=1}
    end,
    function (_,_,mod,_,_)
        --stage 2 (enchancement mult)
        if not (mod==5 or mod==6 or mod==4 and love.chance(5)) then
            return nil
        end
        if mod==6 then
            mult=mult*2
            return {str="X2 Mult",id=4}
        end
        local dmult= (mod==5 and 4 or mod==4 and 20)
        mult=mult+dmult
        return ({str="+"..dmult.." Mult",id=2})
    end,
    function (_,_,mod,_,_)
        --stage 3 (lucky card payout)
        if not (mod==4 and love.chance(15)) then
            return nil
        end
        money=money+20
        return {str="$20",id=3}
    end,
    function (_,_,_,seal,_)
        --stage 4 (gold seal)
        if seal~=3 then return nil end
        money=money+3
        return {str="$3",id=3}
    end,
    function (_,_,_,_,edition)
        --stage 5 (edition bonus)
        if edition==0 then
            return nil
        end
        if edition==1 then
            chips=chips+50
            return {str="+50",id=1}
        end
        if edition==2 then
            mult=mult+10
            return {str="+10 Mult",id=2}
        end
        if edition==3 then
            mult=mult*1.5
            local temp = 10^(3-math.min(math.floor(math.log10(mult)),3))
            mult=math.floor(temp*mult)/temp
            return {str="X1.5 Mult",id=4}
        end
    end
}

scoreCardHandStages = {
    function (_,_,mod,_,_)
        if mod==7 then
            mult=mult*1.5
            local temp = 10^(3-math.min(math.floor(math.log10(mult)),3))
            mult=math.floor(temp*mult)/temp
            return {str="X1.5 Mult",id=4}
        end
        return nil
    end
}


scoreCardScoringReStages = {
    function (_,_,_,seal,_)
        if seal~=4 then return nil end
        return 1
    end
}

scoreCardHandReStages = {
    function (_,_,_,seal,_)
        if seal~=4 then return nil end
        return 1
    end
}

local scorePop

local shouldRetrigger = false
local function scoreCardScoring(ccard)
    -- returns print string + an id for what happened (for appropriate bubble)
    local rank,suite,mod,seal,edition = card.getRank(ccard), card.getSuite(ccard), ccard.mod, ccard.seal, ccard.edit
    local pop,bigStage=nil, scorePop.bigStage
    local cScoreTable,cReTable = scoreCardStages[bigStage],scoreCardReStages[bigStage]
    local maxStage,maxReStage = #cScoreTable,#cReTable
    while not pop and ccardStage<=maxStage do
        pop=cScoreTable[ccardStage](rank,suite,mod,seal,edition)
        ccardStage=ccardStage+1
    end
    if pop then
        shouldRetrigger=true
        return pop
    end
    while shouldRetrigger and not pop and ccardReStage<=maxReStage do
        pop=cReTable[ccardReStage](rank,suite,mod,seal,edition)
        ccardReStage=ccardReStage+1
    end
    if pop then
        ccardStage=1
        if type(pop)=="table" then
            return {str="Again!",id=5,key=pop.key,drawLoc=3}
        end
        return {str="Again!",id=5}
    end
    shouldRetrigger=false
    ccardStage=1
    ccardReStage=1
    return nil
end

local function scoreCardJoker(jslotid)
    return scoreCardStages[3][jslotid] and scoreCardStages[3][jslotid]()
end

scorePop={str="",id=0,key=nil,time=0.7,bigStage=1,drawLoc=1}

local function scorePopUpDraw(screen,myid)
    if screen~="bottom" then
    local pos = playCardStartPos+9+45*scorePop.key
    love.graphics.draw(scoringPopup[scorePop.id],pos,90)
    love.graphics.printf(scorePop.str,pos-19,90,60,"center")
    table.remove(Drawer,myid)
    end
end

local function handPopUpDraw(screen,myid)
    if screen=="bottom" then
    local pos = cOffset+cDist*(scorePop.key-1)+41
    love.graphics.draw(scoringPopup[scorePop.id],pos,98)
    love.graphics.printf(scorePop.str,pos-19,98,60,"center")
    table.remove(Drawer,myid)
    end
end

local function jokerPopUpDraw(screen,myid)
    if screen=="bottom" then
    local pos = joker.joffset+joker.jspace*(scorePop.key-1)+10
    love.graphics.draw(scoringPopup[scorePop.id],pos,62)
    if pos<21 then
        love.graphics.printf(scorePop.str,0,62,48,"center")
        return table.remove(Drawer,myid)
    end
    love.graphics.printf(scorePop.str,pos-21,62,60,"center")
    return table.remove(Drawer,myid)
    end
end

local popUpDraw = {scorePopUpDraw,handPopUpDraw,jokerPopUpDraw}

local function scorePopUpUpdate(dt,myid)
    scorePop.time=scorePop.time-dt
    table.insert(Drawer,popUpDraw[scorePop.drawLoc])
    if scorePop.time<0 then
        table.remove(Updater,myid)
    end
end

local cardJumpTimer

local function cardJumpUpdate(dt,myid)
    cardJumpTimer=cardJumpTimer-dt
    scorePop.jumper.bounce=math.floor(-3*math.sin(cardJumpTimer*math.pi*15)-30*cardJumpTimer)
    if cardJumpTimer<0 then
        table.remove(Updater,myid)
        scorePop.jumper.bounce=0
    end
end


local function jokerScoreAndAnimate(dt,myid)
    scoreTimer=scoreTimer-dt
    table.insert(Drawer,drawPlayedCards)
    if scoreTimer>0 then return end
    local pop
    while true do
    if #sjoke==0 then
        table.remove(Updater,myid)
        scoreTimer=.8
        table.insert(Updater,calcAddScore)
        score=math.ceil(score+chips*mult)
        chips,mult = 0,0
        return
    end
    pop = scoreCardJoker(sjoke[1])
    if pop then break end
    njoker = njoker+1
    table.remove(sjoke,1)
    end
    nScoringEvents=nScoringEvents+1
    table.remove(sjoke,1)
    scorePop=pop
    scorePop.key = scorePop.key or njoker
    njoker = njoker+1
    scorePop.drawLoc=3
    scorePop.jumper=scorePop.jumper or jumpMap[scorePop.drawLoc][scorePop.key]
    scorePop.time=.6
    cardJumpTimer=.1+dt
    if scorePop.id==2 then
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCMultOnly)
    elseif scorePop.id==4 then
    dismult=mult>10^5 and formatNum(mult,5) or mult
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    else
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    end
    scoreTimer=.7
    triggersfx:play()
end

local function prepJokerScoreAndAnimate(dt,myid)
    table.insert(Drawer,drawPlayedCards)
    njoker=1
    sjoke={}
    ccardStage=1
    for i=0, #scoreCardStages[3] do
        sjoke[i]=i
    end
    table.remove(Updater,myid)
    table.insert(Updater,jokerScoreAndAnimate)
end

local popped=false

local function handScoreAndAnimate(dt,myid)
    scoreTimer=scoreTimer-dt
    table.insert(Drawer,drawPlayedCards)
    if scoreTimer>0 then return end
    local pop
    while true do
    pop = scoreCardScoring(shand[1])
    if pop then
        popped=true
        break
    end
    nhcard = nhcard+1
    table.remove(shand,1)
    if #shand==0 then
        table.remove(Updater,myid)
        scoreTimer = popped and .15 or 0
        table.insert(Updater,prepJokerScoreAndAnimate)
        return
    end
    end
    nScoringEvents=nScoringEvents+1
    scorePop=pop
    scorePop.drawLoc = scorePop.drawLoc or 2
    scorePop.bigStage = 2
    scorePop.key = scorePop.key or nhcard
    scorePop.jumper=scorePop.jumper or jumpMap[scorePop.drawLoc][scorePop.key]
    scorePop.time=.6
    cardJumpTimer=.1+dt
    if scorePop.id==2 then
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCMultOnly)
    elseif scorePop.id==4 then
    dismult=mult>10^5 and formatNum(mult,5) or mult
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    else
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    end
    scoreTimer=.7
    triggersfx:play()
end

local function prepHandScoreAndAnimate(dt,myid)
    table.insert(Drawer,drawPlayedCards)
    nhcard=1
    shand={}
    ccardStage=1
    ccardReStage=1
    scorePop.bigStage=2
    for i,v in ipairs(card.hand) do
        shand[i]=v
    end
    table.remove(Updater,myid)
    table.insert(Updater,handScoreAndAnimate)
end


local function scoreAndAnimate(dt,myid)
    scoreTimer=scoreTimer-dt
    table.insert(Drawer,drawPlayedCards)
    if scoreTimer>0 then return end
    local pop
    while true do
    pop = scoreCardScoring(card.toScore[1])
    if pop then break end
    table.remove(card.toScore,1)
    if #card.toScore==0 then
        table.remove(Updater,myid)
        scoreTimer=.15
        table.insert(Updater,prepHandScoreAndAnimate)
        return
    end
    end
    nScoringEvents=nScoringEvents+1
    scorePop=pop
    scorePop.drawLoc = scorePop.drawLoc or 1
    scorePop.bigStage=1
    scorePop.key=scorePop.key or card.toScore[1].playKey
    scorePop.time=.6
    scorePop.jumper=scorePop.jumper or jumpMap[scorePop.drawLoc][scorePop.key]
    cardJumpTimer=.1+dt
    if scorePop.id==2 then
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCMultOnly)
    elseif scorePop.id==4 then
    table.insert(Updater,cardJumpUpdate)
    dismult=mult>10^5 and formatNum(mult,5) or mult
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    else
    table.insert(Updater,cardJumpUpdate)
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    end
    scoreTimer=.7
    triggersfx:play()
end

local tempPreScoreStages = {}

local function preScoreAndAnimate(dt,myid)
    scoreTimer=scoreTimer-dt
    table.insert(Drawer,drawPlayedCards)
    if scoreTimer>0 then return end
    local pop
    while tempPreScoreStages[1] do
    pop = tempPreScoreStages[1]()
    table.remove(tempPreScoreStages,1)
    if pop then break end
    end
    if pop then
        nScoringEvents=nScoringEvents+1
        scorePop=pop
        scorePop.jumper=scorePop.jumper or jumpMap[scorePop.drawLoc][scorePop.key]
        scorePop.time=.55
        cardJumpTimer=.1
        table.insert(Updater,cardJumpUpdate)
        table.insert(Updater,scorePopUpUpdate)
        table.insert(Updater,updateUiCanvas)
        scoreTimer=(#tempPreScoreStages==0 and .8 or.6)
        triggersfx:play()
    else
        prescore=false
        scoreTimer=.3
        scorePop.bigStage=1
        table.insert(Updater,scoreAndAnimate)
        table.remove(Updater,myid)
    end
end

local tempPreDiscardStages = {}

local function preDiscardEffects(dt,myid)
    scoreTimer=scoreTimer-dt
    if scoreTimer>0 then return end
    local pop
    while tempPreDiscardStages[1] do
    pop = tempPreDiscardStages[1]()
    table.remove(tempPreDiscardStages,1)
    if pop then break end
    end
    if pop then
        scorePop=pop
        scorePop.jumper=scorePop.jumper or jumpMap[scorePop.drawLoc][scorePop.key]
        scorePop.time=.55
        cardJumpTimer=.1
        table.insert(Updater,cardJumpUpdate)
        table.insert(Updater,scorePopUpUpdate)
        table.insert(Updater,updateUiCanvas)
        scoreTimer=.6
        triggersfx:play()
    else
        card.discardS(handSize)
        cdiscards=cdiscards-1
        updateHSizeVars(#card.hand)
        card.sortHand()
        cursorid[2] = cursorid[1]==1 and cursorid[2]>#card.hand and #card.hand or cursorid[2]
        animationflag=false
        table.remove(Updater,myid)
        dragsfx:play()
        return table.insert(Updater,updateUiCanvas)
    end
end

local function playSCards()
    animationflag=true
    card.toScore={}
    for _,v in ipairs(scoreIds) do
        card.hselect[v].scoring=true
    end
    local tempaddresses={}
    for k,_ in pairs(card.hselect) do
        table.insert(tempaddresses,k)
        table.sort(tempaddresses)
    end
    for i=#tempaddresses,1,-1 do
        local tadd=tempaddresses[i]
        table.insert(card.play,1,card.hand[tadd])
        table.remove(card.hand,tadd)
        table.insert(card.playcan,0,1)
        card.playcan[1]=card.handcan[tadd]
        table.remove(card.handcan,tadd)
    end
    cOffset=cOffset+math.floor(cDist*#tempaddresses*.5)
    updateBUiCan()
    for i,v in ipairs(card.play) do
        if v.scoring then
            v.playKey=i
            table.insert(card.toScore,v)
        end
    end
    scoreTimer,prescore,nScoringEvents=.6,true,0
    scorePop.bigStage=1
    local temp=#card.play
    playCardStartPos=116+math.floor(22.5*(5-temp))
    jumpMap = {card.play,card.hand,joker.jslots}
    tempPreScoreStages = {}
    for _,v in ipairs(playEffectStages) do
        table.insert(tempPreScoreStages,v)
    end
    table.insert(Drawer,drawPlayedCards)
    table.insert(Updater,preScoreAndAnimate)
end

local demoAnteUp=false

local function postScoreReset()
    for _,v in ipairs(card.play) do
        v.scoring=false
    end
    card.play={}
    card.playcan={}
    card.toScore={}
    card.hselect={}
    if score>blindrq then
        table.insert(Drawer,function (screen)
            if screen~="bottom" then
                love.graphics.print("Congrats!\nPress B to ante up...",200,40)
            end
            demoAnteUp=true
        end)
        return
    end
    if chands==0 then
        demobgmusic:stop()
        table.insert(Drawer,function (screen)
            if screen~="bottom" then
                love.graphics.print("Made it to Ante "..cante.."!\nHit start to exit",200,40)
            end
        end)
        return
    end
    cursorid={1,1}
    card.drawCard(math.max(handSize-#card.hand,0))
    card.sortHand()
    updateHSizeVars(#card.hand)
    nselect=0
    animationflag=false
end

function calcAddScore(dt,myid)
    -- heavily reusing code here... including the chiprate var
    if scoreTimer>0 then
        table.insert(Drawer,drawPlayedCards)
        scoreTimer=scoreTimer-dt
        return
    end
    local dscore= score-dispscore
    local deleteself= dscore==0 and chips==dischips
    table.insert(Drawer,drawToUiCanvas)
    table.insert(Drawer,drawPlayedCards)
    if deleteself then
        chiprate,multrate,imult,ichips=nil,nil,0,0
        postScoreReset()
        scoreupsfx:stop()
        return myid and table.remove(Updater,myid)
    end
    if not chiprate then
        chiprate=math.ceil(dscore/20)
        multrate=dscore
        imult=math.floor(dismult)
        ichips=dischips
        scoreupsfx:play()
    end
    dispscore=dispscore+(dscore/chiprate>1 and chiprate or dscore)
    dispscoreS=formatNum(dispscore,10)
    dismult=math.ceil((multrate-dscore)/multrate*(mult-imult))+imult
    dischips=math.ceil((multrate-dscore)/multrate*(chips-ichips))+ichips
end

function foilScore()
    chips=chips+50
    njoker=njoker-1
    return {str="+50",id=1, key=njoker+1}
end
function holoScore()
    mult=mult+10
    njoker=njoker-1
    return {str="+10 Mult",id=2, key=njoker+1}
end
function polyScore()
    mult=mult*1.5
    local temp = 10^(3-math.min(math.floor(math.log10(mult)),3))
    mult=math.floor(temp*mult)/temp
    njoker=njoker-1
    return {str="X1.5 Mult",id=4}
end



function updateHSizeVars(hsize)
    cDist=math.floor(210/(hsize-1))
    cOffset=math.floor(math.fmod(210/(hsize-1),1)+.5)
end


local debugstring
function love.update(dt)
    for i=#Updater,1,-1 do
        Updater[i](dt,i)
    end
    --[[
    debugstring = ""
    for i,_ in pairs(card.hselect) do
    debugstring=debugstring..i
    end
    --]]
    --statstest=love.graphics.getStats()
    --debugstring=statstest.texturememory.."\n"..statstest.canvases
    --debugstring = ""
    --if scoreIds then
    --for _,v in pairs(scoreIds) do
        --debugstring=debugstring.." "..v
    --end
--end
end


local function anticrashspam(dt,myid)
    spamdelay=spamdelay-dt
    if spamdelay<0 then
        table.remove(Updater,myid)
    end
end


function topScreenDraw(screen,_)
    if screen=="bottom" then return end
    love.graphics.setBlendMode("alpha","alphamultiply")
    --love.graphics.print(debugstring,160,20)
    love.graphics.setBlendMode("alpha","premultiplied")
    love.graphics.draw(uicanvas,0,0)
    love.graphics.draw(blindcan,15,6)
    love.graphics.setBlendMode("alpha","alphamultiply")
end

function drawHandCards(screen,myid)
    if screen~="bottom" then return end
    love.graphics.setBlendMode("alpha","premultiplied")
    love.graphics.draw(bUICan)
    for i,v in ipairs(card.handcan) do
        local ccard=card.hand[i]
        love.graphics.draw(v,(i-1)*cDist+cOffset+33,ccard.selected and 89 or 119 + ccard.bounce)
        if cursorid[1]==1 and i==cursorid[2] then
            love.graphics.draw(dragMode and cursorD or cursor,(i-1)*cDist+cOffset+33,ccard.selected and 89 or 119)
        end
    end
    love.graphics.setBlendMode("alpha","alphamultiply")
end

function drawJokers(screen,_)
    if screen~="bottom" then return end
    love.graphics.setBlendMode("alpha","premultiplied")
    local joff,jdist = joker.joffset,joker.jspace
    for i,v in ipairs(joker.jcan) do
        love.graphics.draw(v,(i-1)*jdist+joff,6 + joker.jslots[i].bounce)
        if cursorid[1]==2 and i==cursorid[2] then
            love.graphics.draw(dragMode and cursorD or cursor,(i-1)*jdist+joff-1,5+joker.jslots[i].bounce)
        end
    end
    love.graphics.setBlendMode("alpha","alphamultiply")
end

function love.draw(screen)
    love.graphics.setBlendMode("alpha","alphamultiply")
    for i=#priorityDrawer,1,-1 do
        priorityDrawer[i](screen,i)
    end
    for i=#Drawer,1,-1 do
        Drawer[i](screen,i)
    end
    love.graphics.print(debugstring, 200,60)
end

local function postDragClarity()
    card.hselect={}
    for i,v in ipairs(card.hand) do
        if v.selected then
            card.hselect[i]=v
         end
    end
    _,_,scoreIds=unpack(idHandTypes())
    dragMode=false
end

local function postJokeClarity()
    joker.postDrag()
    scoreCardStages= _G.scoreCardStages
    scoreCardReStages = _G.scoreCardReStages
    playEffectStages = _G.playEffectStages
    dragMode=false
end

local function prepareDrag(dt,myid)
    aHeldTimer = aHeldTimer and aHeldTimer-dt or -1
    if aHeldTimer<=0 then
        aHeldTimer=nil
        spamdelay=.5
        table.insert(Updater,anticrashspam)
        dragMode=true
        table.remove(Updater,myid)
    end
end

local tempAHold = nil
local demoResetTimer = 0
function love.gamepadpressed(_,button)
    if demoAnteUp and button=="b" then
        card.hand={}
        card.handcan={}
        --[[
        for i=#card.handcan,1,-1 do
            card.handcan[i]:release()
            table.remove(card.handcan,i)
        end
        --]]
        card.deck={}
        collectgarbage("collect")
        for _,v in ipairs(card.fdeck) do
            table.insert(card.deck,v)
        end
        card.drawCard(handSize)
        card.sortHand()
        updateHSizeVars(#card.hand)
        blindrq=blindrq*3
        chands=maxhands
        cdiscards=maxdiscards
        cursorid={1,1}
        nselect=0
        score=0
        cante=cante+1
        dispscore=0
        dispscoreS="0"
        updateBlind(1)
        updateBUiCan()
        table.remove(Drawer,#Drawer)
        table.insert(Drawer,drawToUiCanvas)
        demoAnteUp=false
        animationflag=false
        dragsfx:play()
        return
    end
    if button=="start" then
        love.event.quit()
    end
    if animationflag then return end
    --[[
    if button=="back" then
        demoResetTimer = love.timer.getTime()
    end
    --]]
    if button=="dpleft" then
        if aHeldTimer then
            aHeldTimer=-1
            dragMode=true
        end
        if cursorid[1]==1 then
        if dragMode then
            local idref = cursorid[2]
            if idref==1 then
                local temp,temp2=card.hand[1],card.handcan[1]
                table.remove(card.hand,1)
                table.remove(card.handcan,1)
                table.insert(card.hand,temp)
                table.insert(card.handcan,temp2)
            else
                local temp,temp2=card.hand[idref-1],card.handcan[idref-1]
                card.hand[idref-1],card.handcan[idref-1]=card.hand[idref],card.handcan[idref]
                card.hand[idref],card.handcan[idref]=temp,temp2
            end
            dragsfx:play()
        end
        cursorid[2]=cursorid[2]==1 and #card.hand or cursorid[2]-1
        elseif cursorid[1]==2 then
        if dragMode then
            local idref = cursorid[2]
            if idref==1 then
                local temp,temp2=joker.jslots[1],joker.jcan[1]
                table.remove(joker.jslots,1)
                table.remove(joker.jcan,1)
                table.insert(joker.jslots,temp)
                table.insert(joker.jcan,temp2)
            else
                local temp,temp2=joker.jslots[idref-1],joker.jcan[idref-1]
                joker.jslots[idref-1],joker.jcan[idref-1]=joker.jslots[idref],joker.jcan[idref]
                joker.jslots[idref],joker.jcan[idref]=temp,temp2
            end
            dragsfx:play()
        end
        cursorid[2]=cursorid[2]==1 and #joker.jslots or cursorid[2]-1
        end
    end
    if button=="dpright" then
        if aHeldTimer then
            aHeldTimer=-1
            dragMode=true
        end
        if cursorid[1]==1 then
        if dragMode then
            local idref = cursorid[2]
            if idref==#card.hand then
                local temp,temp2 = card.hand[#card.hand],card.handcan[#card.hand]
                table.remove(card.hand,#card.hand)
                table.remove(card.handcan,#card.handcan)
                table.insert(card.hand,1,temp)
                table.insert(card.handcan,1,temp2)
            else
                local temp,temp2=card.hand[idref+1],card.handcan[idref+1]
                card.hand[idref+1],card.handcan[idref+1]=card.hand[idref],card.handcan[idref]
                card.hand[idref],card.handcan[idref]=temp,temp2
            end
            dragsfx:play()
        end
        cursorid[2]=math.fmod(cursorid[2],#card.hand)+1
        elseif cursorid[1]==2 then
            if dragMode then
                local idref = cursorid[2]
                if idref==#joker.jslots then
                    local temp,temp2 = joker.jslots[#joker.jslots],joker.jcan[#joker.jslots]
                    joker.jslots[#joker.jslots],joker.jcan[#joker.jcan]=nil,nil
                    table.insert(joker.jslots,1,temp)
                    table.insert(joker.jcan,1,temp2)
                else
                local temp,temp2=joker.jslots[idref+1],joker.jcan[idref+1]
                joker.jslots[idref+1],joker.jcan[idref+1]=joker.jslots[idref],joker.jcan[idref]
                joker.jslots[idref],joker.jcan[idref]=temp,temp2
                end
                dragsfx:play()
            end
        cursorid[2]=math.fmod(cursorid[2],#joker.jslots)+1
        end
    end
    if aHeldTimer then return end
    if (button=="dpdown" or button=="dpup") and not dragMode then
        cursorid[1]=3-cursorid[1]
        if cursorid[1]==1 and cursorid[2]>#card.hand then
            cursorid[2] = #card.hand
            return
        elseif cursorid[2]>#joker.jslots then
            cursorid[2] = #joker.jslots
            return
        end
    end
    if button=="rightshoulder" then
        joker.addNewJoker(math.random(2,18),math.random(-1,3))
    end
    if button=="x" then
        if nselect==0 or dragMode or cdiscards<1 then return end
        scoreTimer=-1
        animationflag=true
        nselect=0
        chips=0 mult=0
        tempPreDiscardStages={}
        for _,v in ipairs(preDiscardStages) do
            table.insert(tempPreDiscardStages,v)
        end
        table.insert(Updater,preDiscardEffects)
    end
    if button=="y" then
        if nselect==0 or dragMode then return end
        chands=chands-1
        playSCards()
        dragsfx:play()
        table.insert(Updater,updateUiCanvas)
    end
    if button=="b" then
        if spamdelay>0 or dragMode then return end
        card.sortMode = not card.sortMode
        card.sortHand()
        spamdelay = .4
        table.insert(Updater,anticrashspam)
        return postDragClarity()
    end
    if button=="a" then
        if spamdelay>0 or dragMode or aHeldTimer then return end
        aHeldTimer = .2
        table.insert(Updater,prepareDrag)
        tempAHold=#Updater
    end
end
function love.gamepadreleased(_,button)
    if button=="a" then
        if aHeldTimer then
            if spamdelay>0 or dragMode or cursorid[1]~=1 then aHeldTimer=nil
                return table.remove(Updater,tempAHold) end
            local idref = cursorid[2]
            local t = card.hand[idref]
            if t.selected then
            card.hand[idref].selected=false
            card.hselect[idref]=nil
            nselect=nselect-1
            deselectsfx:play()
            elseif nselect<5 then
            card.hand[idref].selected=true
            card.hselect[idref]=card.hand[idref]
            nselect=nselect+1
            selectsfx:play()
            end
            if nselect==0 then chips=0 mult=0
                table.insert(Updater,updateUiCanvas) 
                aHeldTimer=nil
                return table.remove(Updater,tempAHold)
                end
            local tempid = 0
            hTypes,tempid,scoreIds=unpack(idHandTypes())
            curHand=HandTypes[tempid]
            chips=curHand.bchips
            mult=curHand.bmult
            spamdelay=.3
            table.remove(Updater,tempAHold)
            table.insert(Updater,updateUiCanvas)
            table.insert(Updater,anticrashspam)
            aHeldTimer=nil
        else
            if cursorid[1]==1 then
                return postDragClarity()
            elseif cursorid[1]==2 then
                return postJokeClarity()
            end
        end
    end
    --[[
    if button=="back" then
        if love.timer.getTime()-demoResetTimer > 1 then
            love.event.quit("restart")
        end
    end
    --]]
end