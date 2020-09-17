-- see the history of a specific data source
select "id", "name", "parentId", "operationType", "operationTime", "operationUsername"
from "SYSLOG.DataSourceHistory" 
where "name" = 'ms_sql'
order by "operationTime"
;;

-- list all data sources that have been deleted as last operation
select *
from
	(
	select "id", "name", "parentId", "operationType", "operationTime", "operationUsername"
			, row_number() over (partition by "name" order by "operationTime" desc) as operationPriority
	from "SYSLOG.DataSourceHistory"
	)as sub
where "operationPriority" = 1
	and "operationType" ='DROP'
;;
	
-- list all operations on virtual procedures happened after yesterday
select "name", "operationType", "operationTime", "operationUsername"
from "SYSLOG.ProcDefinitionHistory"
where cast("operationTime" as date) = curdate()
order by "operationTime" desc
;;