-- enforce a retry counter of at least 3 for all jobs that have a counter < 3
select "id", "jobType", left("description", 50) as "description" 
from "SYSADMIN.ScheduleJobs" as jobs
  ,table
  	(exec "SYSADMIN.changeJobParameters"(
          "jobid" => jobs.id,
          "retryCounter" => 3,
          "retryDelay" => 60
      )) as changes
where retryCounter < 3
;;