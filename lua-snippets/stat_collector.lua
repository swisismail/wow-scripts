local HistoricalInterval = 5

local HistoricalStats =    {}       
HistoricalStats['deltaHp1'] =  function() return TMW.CNDT.Env.CountDeltaHp(500) end
HistoricalStats['deltaHp2'] = function() return TMW.CNDT.Env.CountDeltaHp(3000) end
HistoricalStats['bossEtd'] = function ()
    return UnitHealth('boss1')/TMW.CNDT.Env.DeltaUnit('boss1')/HistoricalInterval
end  


local LiveStats = {}

local function getPctLtThd(thd)
    return  function pctLtThd(curTar) 
        local pctHp = UnitHealth(curTar)/UnitHealthMax(curTar)*100 
        return (UnitExists(curTar) and pctHp < thd and true or false)
    end
end 


    
local function hasDispellable(curTar)
    local function dispellable(n,_,_,debuffType ,_,_,_,isStealable)
        if debuffType=="Magic" or debuffType=="Disease" then 
                return true
        end 
        return false
    end
    return TMW.CNDT.Env.HasMyAura(curTar,dispellable)
end 




local function getAuraNameMatcher(name,bySelf)
    local function matchAura(name,bySelf,n,_,_,debuffType ,_,_,_,isStealable)
        if n==name and (bySelf and unitCaster== "player" or true) then 
            return true
        end 
        return false
    end
    return function pctLtThd(curTar) 
        return TMW.CNDT.Env.HasMyAura(curTar,function getAura(n,_,_,debuffType ,_,_,_,isStealable) return matchAura(name,bySelf,n,_,_,debuffType ,_,_,_,isStealable) end)
    end 
end

    
    

LiveStats['hpBelow95'] = function() return  TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(getPctLtThd(95)) end
LiveStats['hpBelow75'] = function() return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(getPctLtThd(80))) end
LiveStats['hpBelow50'] = function() return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(getPctLtThd(60))) end
LiveStats['hpBelow30'] = function() return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(getPctLtThd(40))) end
LiveStats['dispels'] = function()  return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(hasDispellable)) end
LiveStats['EOL'] = function()  return TMW.CNDT.Env.TableLength(TMW.CNDT.Env.FilterBy(getAuraNameMatcher("Echo of Light",true))) end


function TMW.CNDT.Env.GatherStats()
    
    local function updateStatistic(statName)
        if (TMW.CNDT.Env.StatsCache[statName] == nil) then
            TMW.CNDT.Env.StatsCache[statName] = 0
        end
        TMW.CNDT.Env.StatsCache[statName] =  HistoricalStats[statName] and HistoricalStats[statName]() or LiveStats[statName] and LiveStats[statName]()
    end
    
    if (TMW.CNDT.Env.StatsCache == nil) then
        TMW.CNDT.Env.StatsCache = {}    
    end
    
    
    for  key,value in pairs( LiveStats) do
        updateStatistic(key)
    end
    
    if TMW.CNDT.Env.Interval(1,HistoricalInterval) then
        for key,value in pairs(HistoricalStats) do
            updateStatistic(key)
        end
        --DEFAULT_CHAT_FRAME:AddMessage(TMW.CNDT.Env.Dump(TMW.CNDT.Env.StatsCache))
    end
    
    
end 
TMW.CNDT.Env.GatherStats()



