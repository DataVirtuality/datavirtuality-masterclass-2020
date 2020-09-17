begin

-- make a dump of the current state. alternatively, select * can be used, if desired
select "id", left("description", 50) as "description", "disabled"
into dwh.jobs_dump
from "SYSADMIN.ScheduleJobs"
;

-- disable all jobs
select "id"
from "SYSADMIN.ScheduleJobs" as jobs
  , table
    (exec "SYSADMIN.enableSchedulerJob"(
    "id" => jobs.id,
    "enabled" => false)
    ) as changes;

end
;;

-- ... now pefrform some operations ...

-- now all jobs can be reenabled
-- note that the enableSchedulerJob procedure parameter is called "enabled" but the corresponding ScheduleJobs column is called "disabled". hence the not(...) clause
select "backedUpJobs".*, not(backedUpJobs.disabled) as "enabled"
from dwh.jobs_dump as backedUpJobs
  , table
    (exec "SYSADMIN.enableSchedulerJob"(
    "id" => backedUpJobs.id,
    "enabled" => not(backedUpJobs.disabled))
    ) as changes
;;