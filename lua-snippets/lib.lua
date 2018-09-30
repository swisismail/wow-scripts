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

function TMW.CNDT.map(collection,funct)
      local results = {}
     for i, it in ipairs(collection) do
           table.insert (results,funct(it)) 
    end
    return results
end

function TMW.CNDT.Env.FilterBy (filterFuncts,group)
    local results = {}
    for i, filterFunct in ipairs(filterFuncts) do
       local total = 0
        local units = {}
        for i=1, group and TMW.CNDT.Env.TableLength(group) or (GetNumGroupMembers()+1) do
            local curTar = group and group[i] or TMW.CNDT.Env.GetGroupUnit(i)
            if (UnitIsDead(curTar)==false and filterFunct(curTar)) then
                table.insert (units,curTar) 
            end    
            
        end
        table.insert (results,units) 
    end
    return results
end


function TMW.CNDT.Env.HasAura(curTar,matchFunct)
    for i=1,40 do
        if (matchFunct(UnitAura(curTar,i))) then
            return true
        end
    end    
    return false
end

local function TMW.CNDT.Env.wrap(funct,thd)
    function (curtar) return funct(curtar, thd) end
end


local function TMW.CNDT.Env.hpLt(curTar,thd) 
    local pctHp = UnitHealth(curTar)/UnitHealthMax(curTar)*100 
    return (UnitExists(curTar) and pctHp < thd and true or false)

end 

local function TMW.CNDT.Env.deltaGt(curTar,thd)
    return lib.DeltaUnit(curTar) >= thd
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



