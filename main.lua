---[[
    require"nest".init({console="3ds",scale=2})
if arg[2] == "debug" then
    require("lldebugger").start()
end
--]]
local card,cursorid,cursor,nselect,hTypes,scoreIds,fourfinger,shortcut,curHand,animationflag,score,ui,uicanvas,chips,mult,money,chands,cdiscards,maxhands,maxdiscards
local dischips,dismult,chiprate,multrate,spamdelay, cante, blindcan, blindrq, dispscore, imult, ichips, scoringPopup
local updateBlind, bigFont, writeBig
local font18,fonttiny, scoreTimer, prescore, playCardStartPos, scoringDone
local Updater,Drawer,bigFontq={},{},{}
local drawToUiCanvas, calcAddScore

function love.load()
    love.graphics.set3D(false)
    love.graphics.setDefaultFilter("nearest","nearest")
    font18 = love.graphics.newFont("resources/m6x11plus.ttf",18)
    bigFont=love.graphics.newImage("resources/textures/testimfont.png")
    fonttiny=love.graphics.newFont("resources/m6x11plus.ttf",11)
    cursor=love.graphics.newImage("resources/textures/cursor.png")
    ui=love.graphics.newImage("resources/textures/uithing.png")
    scoringPopup={love.graphics.newImage("resources/textures/popup/chips.png"),
    love.graphics.newImage("resources/textures/popup/mult.png"),
    love.graphics.newImage("resources/textures/popup/cash.png"),
    love.graphics.newImage("resources/textures/popup/mult.png"),
    love.graphics.newImage("resources/textures/popup/mult.png")}
    love.graphics.setBackgroundColor(love.math.colorFromBytes(91, 123, 79))
    uicanvas=love.graphics.newCanvas(153,240)
    blindcan=love.graphics.newCanvas(135,71)
    local bigfntatlas={"1","2","3","4","5","6","7","8","9","0",",","$","-"}
    local x=0
    for _,v in ipairs(bigfntatlas) do
        bigFontq[v]=love.graphics.newQuad(x,0,(v=="," and 6 or 14),24,bigFont)
        x=x+(v=="," and 6 or 14)
    end
    chips,dischips=0,0
    mult,dismult=0,0
    spamdelay=0
    money=0
    scoringDone=true
    cante,blindrq=1,4500 --update with function to determine later
    score,dispscore=0,0
    maxhands=4
    maxdiscards=3
    chands=maxhands
    cdiscards=maxdiscards
    Smeared=false
    cursorid=1
    nselect=0
    score=0
    fourfinger=false
    shortcut=false
    love.graphics.setFont(font18)
    card=require "card"
    card.newBasicDeck()
    card.drawCard(8)
    updateBlind(1)
    table.insert(Drawer,drawToUiCanvas)
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
    if #sortedS>(fourfinger and 3 or 4) then
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
                    else
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
        return t:sub(0,1).."."..t:sub(2,(elimit==4 and 4 or 4)).."e"..math.floor(math.log10(num))
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
    --love.graphics.setBlendMode("alpha","alphamultiply")
    if not uicanvas then
        return
    end
    love.graphics.setCanvas(uicanvas)
    love.graphics.draw(ui,12,0)
    love.graphics.setColor(.118,.451,.871)
    love.graphics.printf(chands,86,191,10,"center")
    love.graphics.setColor(.937,.227,.227)
    love.graphics.printf(cdiscards,125,191,10,"center")
    love.graphics.setColor(.827,.675,.149)
    writeBig("$"..money,22,192,44,"center")
    love.graphics.setColor(.827,.573,.149)
    love.graphics.printf("Ante "..cante.."/8",83,215,56,"center")
    love.graphics.setColor(.102,.149,.184)
    love.graphics.printf(dischips,34,144,35,"right")
    love.graphics.printf(dismult,96,144,35,"left")
    love.graphics.setColor(1,1,1)
    love.graphics.printf(dischips,33,143,35,"right")
    love.graphics.printf(dismult,95,143,35,"left")
    if (nselect>0) then
        love.graphics.printf(curHand.name,font18,25,121,114,"center")
        love.graphics.printf("lvl "..curHand.lvl,fonttiny,71,136,22,"center")
    end
    love.graphics.printf(dispscore,font18,25,93,116,"center")
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
        chiprate=math.ceil(math.abs(dchips)/20)*(dchips>0 and 1 or -1)
        multrate=dchips
        imult=dismult
    end
    dischips=dischips+(dchips/chiprate>1 and chiprate or dchips)
    dismult=math.floor((multrate-dchips)/multrate*(mult-imult))+imult
end

local function updateUiCMultOnly(dt,myid)
    local dmult = mult-dismult
    local deleteself= dmult==0
    table.insert(Drawer,drawToUiCanvas)
    if deleteself then
        chiprate,multrate,imult=nil,nil,0
        return myid and table.remove(Updater,myid)
    end
    if not chiprate then
        chiprate=math.ceil(math.abs(dmult)/20)*(dmult>0 and 1 or -1)
    end
    dismult=dismult+(dmult/chiprate>1 and chiprate or dmult)
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
            love.graphics.draw(v,playCardStartPos+45*i,(not prescore and card.play[i].scoring and 111 or 129))
        end
        love.graphics.setBlendMode("alpha","alphamultiply")
        table.remove(Drawer,myid)
    end
end

local function chance(denominator)
    return love.math.random(1,denominator)==1
end

local ccardStage = 1
local ccardReStage=1

local scoreCardScoringStages = {
    function (rank,_,mod,_,_,_)
        --stage 1 (always returns nonzero)
        local dchip= (rank==99 and 50 or rank==14 and 11 or rank>9 and 10 or rank)+(mod==3 and 30 or 0)
        chips=chips+dchip
        return {str="+"..dchip,id=1}
    end,
    function (_,_,mod,_,_)
        --stage 2 (enchancement mult)
        if not (mod==5 or mod==4 and chance(5)) then
            return nil
        end
        if mod==6 then
            mult=mult*2
            return {str="x2 Mult",id=4}
        end
        local dmult= (mod==5 and 4 or mod==4 and 20)
        mult=mult+dmult
        return ({str="+"..dmult,id=2})
    end,
    function (_,_,mod,_,_)
        --stage 3 (lucky card payout)
        if not (mod==4 and chance(15)) then
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
            return {str="+10",id=2}
        end
        if edition==3 then
            mult=mult*1.5
            return {str="x1.5 Mult",id=4}
        end
    end
}

local scoreCardScoringReStages = {
    function (_,_,_,seal,_)
        if seal~=4 then return nil end
        return 1
    end
}



local function scoreCardScoring(ccard)
    -- returns print string + an id for what happened (for appropriate bubble)
    local rank,suite,mod,seal,edition = card.getRank(ccard), card.getSuite(ccard), ccard.mod, ccard.seal, ccard.edit
    local pop,maxStage,maxReStage=nil,#scoreCardScoringStages,#scoreCardScoringReStages
    while not pop and ccardStage<=maxStage do
        pop=scoreCardScoringStages[ccardStage](rank,suite,mod,seal,edition)
        ccardStage=ccardStage+1
    end
    if pop then
        return pop
    end
    while not pop and ccardReStage<=maxReStage do
        pop=scoreCardScoringReStages[ccardReStage](rank,suite,mod,seal,edition)
        ccardReStage=ccardReStage+1
    end
    if pop then
        ccardStage=1
        return {str="Again!",id=5}
    end
    ccardStage=1
    ccardReStage=1
    return nil
end

local scorePop={str="",id=0,key=0,time=0}

local function scorePopUpDraw(screen,myid)
    if screen~="bottom" then
    local pos = playCardStartPos+9+45*scorePop.key
    love.graphics.draw(scoringPopup[scorePop.id],pos,90)
    love.graphics.printf(scorePop.str,pos-3,90,26,"center")
    table.remove(Drawer,myid)
    end
end

local function scorePopUpUpdate(dt,myid)
    scorePop.time=scorePop.time+dt
    table.insert(Drawer,scorePopUpDraw)
    if scorePop.time>.7 then
        table.remove(Updater,myid)
    end
end

local function scoreAndAnimate(dt,myid)
    scoreTimer=scoreTimer+dt
    table.insert(Drawer,drawPlayedCards)
    if prescore and scoreTimer>.7 then
        prescore=false
    end
    if scoreTimer<1.7 then return end
    local pop
    while true do
    pop = scoreCardScoring(card.toScore[1])
    if pop then break end
    table.remove(card.toScore,1)
    if #card.toScore==0 then
        -- will add in hand + jokers in between these two steps later...
        table.remove(Updater,myid)
        table.insert(Updater,calcAddScore)
        score=score+chips*mult
        chips,mult = 0,0
        return
    end
    end
    scorePop=pop
    scorePop.key=card.toScore[1].playKey
    scorePop.time=0
    if scorePop.id==2 or scorePop.id==4 then
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCMultOnly)
    else
    table.insert(Updater,scorePopUpUpdate)
    table.insert(Updater,updateUiCanvas)
    end
    scoreTimer=scoreTimer-1.2
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
    end
    for i=#tempaddresses,1,-1 do
        local tadd=tempaddresses[i]
        table.insert(card.play,1,card.hand[tadd])
        card.hand[tadd]=false
        table.insert(card.playcan,0,1)
        card.playcan[1]=card.handcan[tadd]
        card.handcan[tadd]=love.graphics.newCanvas(10,10)
    end
    card.hselect={}
    for i,v in ipairs(card.play) do
        if v.scoring then
            v.playKey=i
            table.insert(card.toScore,v)
        end
    end
    scoreTimer,prescore=0,true
    local temp=#card.play
    playCardStartPos=116+math.floor(22.5*(5-temp))
    table.insert(Drawer,drawPlayedCards)
    table.insert(Updater,scoreAndAnimate)
end

local function postScoreReset()
    local drawCount=0
    for i=#card.hand,1,-1 do
        if not card.hand[i] then
            table.remove(card.handcan,i)
            table.remove(card.hand,i)
            drawCount=drawCount+1
        end
    end
    card.play={}
    card.playcan={}
    card.toScore={}
    cursorid=1
    card.drawCard(drawCount)
    nselect=0
    if chands==0 then
        fourfinger=false
        Smeared=false
        shortcut=false
        table.insert(Drawer,function (screen)
            if screen~="bottom" then
                if score<blindrq then
                    love.graphics.print("Too bad... \nHit start to exit\n(May Crash)",200,40)
                else
                    love.graphics.print("...How did you win?!?\nCongrats!!\nBut winning hasn't been\nadded yet...",200,40)
                end
            end
        end)
        return
    end
    animationflag=false
end

function calcAddScore(_,myid)
    -- heavily reusing code here... including the chiprate name 
    local dscore= score-dispscore
    local deleteself= dscore==0 and chips==dischips and mult==dismult
    table.insert(Drawer,drawToUiCanvas)
    table.insert(Drawer,drawPlayedCards)
    if deleteself then
        chiprate,multrate,imult,ichips=nil,nil,0,0
        postScoreReset()
        return myid and table.remove(Updater,myid)
    end
    if not chiprate then
        chiprate=math.ceil(dscore/20)
        multrate=dscore
        imult=dismult
        ichips=dischips
    end
    dispscore=dispscore+(dscore/chiprate>1 and chiprate or dscore)
    dismult=math.ceil((multrate-dscore)/multrate*(mult-imult))+imult
    dischips=math.ceil((multrate-dscore)/multrate*(chips-ichips))+ichips
end

function love.update(dt)
    for i=#Updater,1,-1 do
        Updater[i](dt,i)
    end
end


local function anticrashspam(dt,myid)
    spamdelay=spamdelay-dt
    if spamdelay<0 then
        table.remove(Updater,myid)
    end
end



local debugstring = ""

function love.draw(screen)
    love.graphics.setBlendMode("alpha","alphamultiply")
    if screen~="bottom" then
    --[[ Debug Text
    --love.graphics.print(#card.hand.."\n"..cursorid.."\n"..#card.hselect.."\nFPS: "..love.timer.getFPS())
    love.graphics.print(debugstring,160,90)
    if nselect>0 then
        love.graphics.print(curHand.name,200,45)
        love.graphics.print("Chips: "..curHand.bchips.."   Mult: "..curHand.bmult,200,72)
    end
    --]]
    if shortcut then
        love.graphics.print("Shortcut Active",200,95)
    end
    if fourfinger then
        love.graphics.print("Four Fingers Active",200,110)
    end
    if Smeared then
        love.graphics.print("Smeared Joker Active",200,125)
    end
    --[[
    if Updater[1] and chiprate then
        love.graphics.print("BALLS"..chiprate.."\n"..#Updater,300,40)
    end
    --]]
    love.graphics.setBlendMode("alpha","premultiplied")
    love.graphics.draw(uicanvas,0,0)
    love.graphics.draw(blindcan,15,6)
    love.graphics.setBlendMode("alpha","alphamultiply")
    else
    love.graphics.setBlendMode("alpha","premultiplied")
    for i,v in ipairs(card.handcan) do
        local ccard=card.hand[i]
        if ccard then
        love.graphics.draw(v,i*30-1,ccard.selected and 89 or 119)
        if i==cursorid then
            love.graphics.draw(cursor,i*30-1,ccard.selected and 89 or 119)
        end
    end
    end
    end
    love.graphics.setBlendMode("alpha","alphamultiply")
    for i=#Drawer,1,-1 do
        Drawer[i](screen,i)
    end
end

function love.gamepadpressed(_,button)
    if button=="start" then
        love.event.quit()
        --[[
        card.hand={}
        card.handcan={}
        nselect=0
        card.hselect={}
        card.drawCard(8)
        --debugstring = ""
        chips=0 mult=0
        table.insert(Updater,updateUiCanvas)
        --]]
    end
    if animationflag then return end
    --[[
    if button=="back" then
        card.debugHand()
        nselect=0
        card.hselect={}
        debugstring = ""
        chips=0 mult=0
        table.insert(Updater,updateUiCanvas)
    end
    --]]
    if button=="dpleft" then
        cursorid=cursorid==1 and #card.hand or cursorid-1
    end
    if button=="dpright" then
        cursorid=math.fmod(cursorid,#card.hand)+1
    end
    if button=="leftshoulder" then
        fourfinger= not fourfinger
    end
    if button=="rightshoulder" then
        shortcut= not shortcut
    end
    if button=="dpdown" then
        Smeared=not Smeared
    end
    if button=="x" then
        if nselect==0 then return end
        if cdiscards<1 then return end
        nselect=0
        chips=0 mult=0
        card.discardS(8)
        cdiscards=cdiscards-1
        return table.insert(Updater,updateUiCanvas)
    end
    if button=="y" then
        if nselect==0 then return end
        chands=chands-1
        playSCards()
        table.insert(Updater,updateUiCanvas)
    end
    if button=="b" then
        if spamdelay>0 then return end
        local t = card.hand[cursorid]
        if t.selected then
            card.hand[cursorid].selected=false
            card.hselect[cursorid]=nil
            nselect=nselect-1
        if nselect==0 then chips=0 mult=0 return table.insert(Updater,updateUiCanvas) end
        local tempid = 0
        hTypes,tempid,scoreIds=unpack(idHandTypes())
        curHand=HandTypes[tempid]
        --[[
        for i,_ in pairs(hTypes) do
            debugstring=debugstring.." + "..i
        end
        debugstring=debugstring.."\n"
        for _,v in pairs(scoreIds) do
            debugstring=debugstring.."&"..v
        end
        --]]
        chips=curHand.bchips
        mult=curHand.bmult
        spamdelay=.3
        table.insert(Updater,updateUiCanvas)
        table.insert(Updater,anticrashspam)
        end
    end
    if button=="a" then
        if spamdelay>0 then return end
        local t = card.hand[cursorid]
        if t.selected then
            card.hand[cursorid].selected=false
            card.hselect[cursorid]=nil
            nselect=nselect-1
        elseif nselect<5 then
            card.hand[cursorid].selected=true
            card.hselect[cursorid]=card.hand[cursorid]
            nselect=nselect+1
        end
        --debugstring = ""
        if nselect==0 then chips=0 mult=0 return table.insert(Updater,updateUiCanvas) end
        local tempid = 0
        hTypes,tempid,scoreIds=unpack(idHandTypes())
        curHand=HandTypes[tempid]
        --[[
        for i,_ in pairs(hTypes) do
            debugstring=debugstring.." + "..i
        end
        debugstring=debugstring.."\n"
        for _,v in pairs(scoreIds) do
            debugstring=debugstring.."&"..v
        end
        --]]
        chips=curHand.bchips
        mult=curHand.bmult
        spamdelay=.3
        table.insert(Updater,updateUiCanvas)
        table.insert(Updater,anticrashspam)
    end
end
