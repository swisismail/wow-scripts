local HistoricalInterval = 5
local lib = TMW.CNDT.Env;
local dao = TMW.CNDT.Env;


local function processStatsDef(statsDef,results)
    local function updateStatistic(statName,value)
        if (dao.StatsCache[statName] == nil) then
            dao.StatsCache[statName] = 0
        end
        
        dao.StatsCache[statName] =  HistoricalStats[statName] and value or LiveStats[statName] and value
    end
    
    local results = lib.map(
        lib.FilterBy(
            statsDef
            ),
            lib.TableLength
        )
        
    local kk = 0
    for  key,value in pairs( statsDef) do
        updateStatistic(key,results[kk])
        kk = kk + 1
    end
end


    
local function dispellable(n,_,_,debuffType ,_,_,_,isStealable)
    if debuffType=="Magic" or debuffType=="Disease" then 
            return true
    end 
    return false
end

local function getAuraNameMatcher(name,bySelf)
    return function (n,_,_,debuffType ,_,_,_,isStealable)
        if n==name and (bySelf and unitCaster== "player" or true) then 
            return true
        end 
        return false
    end
end


dao.StatsCache = {}

local LiveStats = {}
local HistoricalStats =    {} 



HistoricalStats['deltaHp1'] =  wrap(deltaGt,500)
HistoricalStats['deltaHp2'] = wrap(deltaGt,3000)
--HistoricalStats['bossEtd'] = function ()
--    return UnitHealth('boss1')/lib.DeltaUnit('boss1')/HistoricalInterval
--end
LiveStats['hpBelow95'] = wrap(lib.hpLt, 95) 
LiveStats['hpBelow75'] = wrap(lib.hpLt,80) 
LiveStats['hpBelow50'] = wrap(lib.hpLt,60)
LiveStats['hpBelow30'] = wrap(lib.hpLt,40) 
LiveStats['dispels'] = wrap(lib.HasAura,dispellable)
LiveStats['EOL'] = wrap(lib.HasAura,getAuraNameMatcher("Echo of Light",true))


function TMW.CNDT.Env.GatherStats()
    processStatsDef(LiveStats,results)
    
    if lib.Interval(1,HistoricalInterval) then
        processStatsDef(HistoricalStats,results)
        --DEFAULT_CHAT_FRAME:AddMessage(lib.Dump(dao.StatsCache))
    end
end 

TMW.CNDT.Env.GatherStats()



