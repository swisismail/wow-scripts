local HistoricalInterval = 5

local HistoricalStats =    {}       
HistoricalStats['deltaHp1'] =  function() return TMW.CNDT.Env.CountDeltaHp(500) end
HistoricalStats['deltaHp2'] = function() return TMW.CNDT.Env.CountDeltaHp(3000) end
HistoricalStats['bossEtd'] = function ()
    return UnitHealth('boss1')/TMW.CNDT.Env.DeltaUnit('boss1')/HistoricalInterval
end  
--HistoricalStats['lowCluster8'] = function() return TMW.CNDT.Env.FindClusterGt(TMW.CNDT.Env.FilterByHp(101),1,1 ) and 1 or 0 end


local LiveStats = {}

LiveStats['hpBelow95'] = function() return TMW.CNDT.Env.CountByHp(95) end
LiveStats['hpBelow75'] = function() return TMW.CNDT.Env.CountByHp(80) end
LiveStats['hpBelow50'] = function() return TMW.CNDT.Env.CountByHp(60) end
LiveStats['hpBelow30'] = function() return TMW.CNDT.Env.CountByHp(40) end
LiveStats['dispels'] = function()  return TMW.CNDT.Env.CountByDispellable() end
LiveStats['dispels'] = function()  return TMW.CNDT.Env.CountByAura("Echo of Light") end
LiveStats['EOL'] = function()  return TMW.CNDT.Env.CountByAura("Echo of Light") end


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



