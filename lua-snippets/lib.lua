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
    for i, it in pairs(collection) do
        results[i] = funct(it)
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
            --DEFAULT_CHAT_FRAME:AddMessage(k..(filterFunct(curTar) and 'true' or 'false'))
            
            if (UnitIsDead(curTar)==false and filterFunct(curTar)) then
                --DEFAULT_CHAT_FRAME:AddMessage(k..curTar)
                table.insert (units,curTar)
                
            end    
            
        end
        
        if lib.TableLength(units) >= 1 then
            results[k] = units
        end
        
        --DEFAULT_CHAT_FRAME:AddMessage(lib.Dump(units))
    end
    --DEFAULT_CHAT_FRAME:AddMessage(lib.Dump(results))
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
    local usable, nomana = IsUsableSpell("Heal");
    return (usable and UnitExists(curTar) and pctHp < thd and true or false)
end 
function lib.getUniqDeltaGt(key)
    return function (curTar,thd)
        return lib.DeltaUnit(key,curTar) >= thd
    end
end



function lib.Interval(uid,seconds)
    dao.monitors[uid] = dao.monitors[uid] and dao.monitors[uid]+1 or 0
    if  dao.monitors[uid] >= 6*seconds  then
        dao.monitors[uid] = 0
        return true
    end
    return false
end
function  lib.DeltaUnit(key,unit)
    
    if (dao.uhpm[key] == nil) then
        dao.uhpm[key] = {}
    end
    
    local hp =  UnitHealth(unit)
    if (dao.uhpm[key][unit] == nil) then
        dao.uhpm[key][unit] = hp
    end
    
    local delta = dao.uhpm[key][unit]  -  hp
    dao.uhpm[key][unit] = hp
    
    return delta
end

function lib.get(key) 
    return dao.StatsCache and dao.StatsCache[key] or 0
end

function lib.getBool(key) 
    return dao.StatsCache and dao.StatsCache[key] or false
end


function lib.groupSize()
    return (GetNumGroupMembers()+1)
end



return lib


