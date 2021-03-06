local dao = TMW.CNDT.Env.dao;
local lib = TMW.CNDT.Env.lib;
local _ = TMW.CNDT.Env._;
local function processStatsDef(statsDef,results)
    
    
    
    local function updateStatistic(statName,value)
        
        
        if (dao.StatsCache[statName] == nil) then
            dao.StatsCache[statName] = 0
        end
        
        dao.StatsCache[statName] =  statsDef[statName] and value
    end
    
    local results = lib.map(
        lib.FilterBy(
            statsDef
        ),
        lib.TableLength
    )
    
    
    -- DEFAULT_CHAT_FRAME:AddMessage(lib.Dump(results))
    --local kk = 1
    for  key,value in pairs( statsDef) do
        updateStatistic(key,results[key])
        --kk = kk + 1
    end
end

local function dispellable(n,_,_,debuffType ,_,_,_,isStealable)
    if debuffType=="Magic" or debuffType=="Disease" then 
        return true
    end 
    return false
end
local function getAuraNameMatcher(name,bySelf)
    return function (n,_1,_2,debuffType ,_3,_4,unitCaster,isStealable)
        
        if n==name and (bySelf and unitCaster== "player" or true) then 
            DEFAULT_CHAT_FRAME:AddMessage(isStealable)
            return true
        end 
        return false
    end
end
local HistoricalInterval = 5
local HistoricalStats =    {} 

--HistoricalStats['default'] = nil
HistoricalStats['deltaHp1'] =  lib.wrap(lib.getUniqDeltaGt('deltaHp1'),3000)
HistoricalStats['deltaHp2'] = lib.wrap(lib.getUniqDeltaGt('deltaHp2'),6000)
HistoricalStats['deltaHp3'] = lib.wrap(lib.getUniqDeltaGt('deltaHp2'),12000)
--HistoricalStats['bossEtd'] = function ()
--    return UnitHealth('boss1')/lib.DeltaUnit('boss1')/HistoricalInterval
--end
local LiveStats = {}
--LiveStats['default'] = nil
LiveStats['hpBelow95'] = lib.wrap(lib.hpLt, 95) 
LiveStats['hpBelow75'] = lib.wrap(lib.hpLt,80) 
LiveStats['hpBelow50'] = lib.wrap(lib.hpLt,60)
LiveStats['hpBelow30'] = lib.wrap(lib.hpLt,40) 
LiveStats['dispels'] = lib.wrap(lib.HasAura,dispellable)
LiveStats['EOL'] = lib.wrap(lib.HasAura,getAuraNameMatcher("Echo of Light",true))
LiveStats['renews'] = lib.wrap(lib.HasAura,getAuraNameMatcher("Renew",true))

function TMW.CNDT.Env.GatherStats()
    processStatsDef(LiveStats,results)
    if lib.Interval(1,HistoricalInterval) then
        processStatsDef(HistoricalStats,results)
        DEFAULT_CHAT_FRAME:AddMessage(lib.Dump(dao.StatsCache))
        
        
    end
    dao.StatsCache['massprio'] = lib.groupSize()>3 and (lib.get('hpBelow50') < 1 or lib.get('hpBelow50')/lib.groupSize()*100 >= 50)
end 
TMW.CNDT.Env.GatherStats()

