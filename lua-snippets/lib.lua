--time
if (monitors == nil) then
    monitors = {}    
end

--history
if (uhpm == nil) then
    uhpm = {}
end

function TMW.CNDT.Env.Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. TMW.CNDT.Env.Dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function TMW.CNDT.Env.TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function TMW.CNDT.Env.GetGroupUnit(i)
    return UnitExists("raid"..i) and "raid"..i or UnitExists("party"..i) and "party"..i or "player"
end


function TMW.CNDT.Env.FilterBy (filterFunct,group)
    local total = 0
    local units = {}
    for i=1, group and TMW.CNDT.Env.TableLength(group) or (GetNumGroupMembers()+1) do
        local curTar = group and group[i] or TMW.CNDT.Env.GetGroupUnit(i)
        if (UnitIsDead(curTar)==false and filterFunct(curTar)) then
            table.insert (units,curTar) 
        end    
        
    end
    return units
end

function TMW.CNDT.Env.FilterByHp (thd) 
    local function pctLtThd(curTar) 
        local pctHp = UnitHealth(curTar)/UnitHealthMax(curTar)*100 
        return (UnitExists(curTar) and pctHp < thd and true or false)
    end 
    
    return  TMW.CNDT.Env.FilterBy(pctLtThd)
end


function TMW.CNDT.Env.CountByHp (thd)
    
    local function pctLtThd(curTar) 
        local pctHp = UnitHealth(curTar)/UnitHealthMax(curTar)*100 
        return (UnitExists(curTar) and pctHp < thd and true or false)
    end 
    
    return  TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterByHp(thd))
    
end
function TMW.CNDT.Env.CountByDispellable ()
    local function hasDispellable(curTar) 
        for i=1,20 do
            local n,_,_,debuffType ,_,_,_,isStealable=UnitDebuff(curTar,i);
            local y = 0
            if debuffType=="Magic" or debuffType=="Disease" then 
                return true
            end 
        end
        return false
    end 
    
    return TMW.CNDT.Env.TableLength( TMW.CNDT.Env.FilterBy(hasDispellable))
    
end

function TMW.CNDT.Env.CountByAura (thd)
    
    local function pctLtThd(curTar) 
        return TMW.CNDT.Env.HasMyAura(curTar,name)
    end 
    
    return  TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(pctLtThd))
    
end


function TMW.CNDT.Env.HasMyAura(curTar,name)
    for i=1,40 do
        local n,_,_,debuffType,_,_,unitCaster,isStealable=UnitAura(curTar,i);
        if n then
            
            DEFAULT_CHAT_FRAME:AddMessage('test'..n)
        end
        if n==name and unitCaster== "player" then 
            return true
        end 
    end    
    return false
end



function TMW.CNDT.Env.Interval(uid,seconds)
    monitors[uid] = monitors[uid] and monitors[uid]+1 or 0
    if  monitors[uid] >= 6*seconds  then
        monitors[uid] = 0
        return true
    end
    return false
end


function  TMW.CNDT.Env.DeltaUnit(unit)
    local hp =  UnitHealth(unit)
    if (uhpm[unit] == nil) then
        uhpm[unit] = hp
    end
    
    local delta = uhpm[unit]  -  hp
    uhpm[unit] = hp
    
    return delta
end


function TMW.CNDT.Env.CountDeltaHp(thd)
    local function cond(curTar)
        return TMW.CNDT.Env.DeltaUnit(curTar) >= 500
    end     
    
    return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(cond))
end

--TMW.CNDT.Env.HasMyAura(curTar,"Renew")


