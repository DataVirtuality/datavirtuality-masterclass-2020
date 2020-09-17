-- list peak resource usage across all of todays requests
select sessionId, requestId
		, max(queryHeapAllocated) as maxHeap
		, max(cpuUsageInPercent) as maxCpuInPercent
		, max(totalBuffers)	as maxBuffers
		, max(bufferMemoryUsage) as maxBufferMemory
		
from "SYSLOG.QueryPerformanceLog"
where cast(startTime as date) = curdate()
group by sessionId, requestId
order by maxHeap desc, maxCpuInPercent desc
;;

-- find time window with the highest resource consumption 
select timestampadd(sql_tsi_minute,  minute(startTime), timestampadd(sql_tsi_hour, hour(startTime), cast(curdate() as timestamp)))
		, sum(queryHeapAllocated) as totalHeap
		, sum(cpuUsageInPercent) as totalCpuInPercent
		, sum(totalBuffers)	as totalBuffers
		, sum(bufferMemoryUsage) as totalBufferMemory		
from "SYSLOG.QueryPerformanceLog"
where cast(startTime as date) = curdate()
group by hour(startTime), minute(startTime)
order by totalHeap desc, totalCpuInPercent desc
;;