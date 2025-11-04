local me = {bluestorm=true}
--DO SHIFTUPDATE FIRST BEFORE ADDING JOKER!
function me.onBuy()
    me.myjslotid=#joker.jslots
end

local function copySet(copyTarget,list)
    for _,k in ipairs(list) do
        if k=="onSell" then
            me[k]=function (sold)
                local temp = copyTarget[k](sold)
                if temp then
                    temp.key = me.myjslotid
                end
                return temp
            end
        else
        me[k]=function (rank,suite,mod,seal,edit)
            local temp = copyTarget[k](rank,suite,mod,seal,edit)
            if temp then
                if temp.jumper then
                    temp.jumper = joker.jslots[me.myjslotid]
                else
                    temp.key = me.myjslotid
                end
            end
            return temp
        end
        end
    end
end

local function copyAll(copyTarget)
    for k,v in pairs(copyTarget) do
        if type(v)=="function" and k~="onBuy" and k~="shiftUpdate" then
            if k=="onSell" then
                me[k]=function (sold)
                    local temp = v(sold)
                    if temp then
                        temp.key = me.myjslotid
                    end
                    return temp
                end
            else
            me[k]=function (rank,suite,mod,seal,edit)
                local temp = v(rank,suite,mod,seal,edit)
                if temp then
                    if temp.jumper then
                        temp.jumper = joker.jslots[me.myjslotid]
                    else
                        temp.key = me.myjslotid
                    end
                end
                return temp
            end
        end
        end
    end
end

local function resetMe()
    for k,_ in pairs(me) do
        me[k]=nil
    end
end

function me.shiftUpdate()
    local temp,temp2,temp3=me.myjslotid,me.shiftUpdate,me.edit
    resetMe()
    me.bluestorm=true  me.myjslotid=temp  me.shiftUpdate=temp2  me.edit=temp3  me.bounce=0
    if temp==1 or joker.jslots[1].noCopy then
        return
    end
    local copyTarget=joker.jslots[1]
    if copyTarget.copyIndx then
        return copySet(copyTarget,copyTarget.copyIndx)
    end
    copyAll(copyTarget)
    print(me.onJoker)
end
return me