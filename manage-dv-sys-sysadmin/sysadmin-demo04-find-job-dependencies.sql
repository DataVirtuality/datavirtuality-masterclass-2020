-- find all jobs and schedules that existing jobs depend on
select 	jobId, chainString
		-- if the predecessor's id starts with a J then it is a job, otherwise a schedule
		, case when
			dependencies.dependentId like 'J%' then 'job'
			else 'schedule' 
		end as dependentObjectType
		, replace(dependencies.dependentId, 'J', '') as dependentObjectId
		, dependencies.dependencyType

-- each ampersand (&) denotes a new dependency and the '=' separates the predecessor object from the return status that triggers the main job
from "SYSADMIN.Schedules"
	, texttable(chainString
		columns
		dependentId string,
		dependencyType string
		row delimiter '&'
		delimiter '='
	)as dependencies

where type = 'CHAINED'
;;