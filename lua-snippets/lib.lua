TMW.CNDT.Env.lib = {}
local dao = TMW.CNDT.Env.dao;
local lib = TMW.CNDT.Env.lib;
function lib.Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. lib.Dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
function lib.TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
function lib.map(collection,funct)
    local results = {}
    for i, it in ipairs(collection) do
        table.insert (results,funct(it)) 
    end
    return results
end
function lib.FilterBy (filterFuncts,group)
    local results = {}
    
    
    for k, filterFunct in pairs(filterFuncts) do
        local total = 0
        local units = {}
        for i=1, group and lib.TableLength(group) or (GetNumGroupMembers()+1) do
            local curTar = group and group[i] or lib.GetGroupUnit(i)
            if (UnitIsDead(curTar)==false and filterFunct(curTar)) then
                table.insert (units,curTar) 
            end    
            
        end
        table.insert (results,units) 
    end
    return results
end
function lib.wrap(funct,thd)
    return function (curtar) return funct(curtar,thd) end
end
function lib.GetGroupUnit(i)
    return UnitExists("raid"..i) and "raid"..i or UnitExists("party"..i) and "party"..i or "player"
end
function lib.HasAura(curTar,matchFunct)
    for i=1,40 do
        if (matchFunct(UnitAura(curTar,i))) then
            return true
        end
    end    
    return false
end
function lib.hpLt(curTar,thd) 
    local pctHp = UnitHealth(curTar)/UnitHealthMax(curTar)*100 
    return (UnitExists(curTar) and pctHp < thd and true or false)
end 
function lib.deltaGt(curTar,thd)
    return lib.DeltaUnit(curTar) >= thd
end 

function lib.Interval(uid,seconds)
    dao.monitors[uid] = dao.monitors[uid] and dao.monitors[uid]+1 or 0
    if  dao.monitors[uid] >= 6*seconds  then
        dao.monitors[uid] = 0
        return true
    end
    return false
end
function  lib.DeltaUnit(unit)
    local hp =  UnitHealth(unit)
    if (dao.uhpm[unit] == nil) then
        dao.uhpm[unit] = hp
    end
    
    local delta = dao.uhpm[unit]  -  hp
    dao.uhpm[unit] = hp
    
    return delta
end

return lib

