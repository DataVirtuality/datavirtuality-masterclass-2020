-- get the max running time for each job (by id) across all successful runs
-- multiply by a constant (here 1.5) to add some buffer in
-- but only consider jobs with a running time longer than a certain threshold (here 10 minutes)

-- variant with loop
begin
	loop on(	select jobid
					, avg(timestampdiff(sql_tsi_minute, starttime, endtime)) as averageSuccessRunningTime
					, max(timestampdiff(sql_tsi_minute, starttime, endtime)) as maxSuccessRunningTime
					, cast(ceiling(avg(timestampdiff(sql_tsi_minute, starttime, endtime))*1.5) as integer) as jobTimeoutSetting
				from "SYSLOG.JobLogs"
				where status = 'SUCCESS' and jobid > 7 -- jobs 1-7 are system cleanup jobs. can be skipped
				group by jobid
				
				--only change jobs that cross a cetain threshold for the calculated timeout setting. here: onlyjobs that usually run longer than 10 minutes
				having ceiling(avg(timestampdiff(sql_tsi_minute, starttime, endtime))*1.5) > 10
			)as cur
	begin
	begin
		exec "SYSADMIN.changeJobParameters"(
			    "jobid" => cur.jobid,
			    "runTimeout" => cur.jobTimeoutSetting);
    end
    exception e
    begin
    	--do nothing and just skip faulty procedure calls
    end
	end
end
;;


-- variant with table expression
select *
from	(
		select jobid
			, avg(timestampdiff(sql_tsi_minute, starttime, endtime)) as averageSuccessRunningTime
			, max(timestampdiff(sql_tsi_minute, starttime, endtime)) as maxSuccessRunningTime
			, cast(ceiling(max(timestampdiff(sql_tsi_minute, starttime, endtime))*1.5) as integer) as jobTimeoutSetting
		from "SYSLOG.JobLogs"
		where status = 'SUCCESS' and jobid > 7 -- jobs 1-7 are system cleanup jobs. can be skipped
		group by jobid
		
		--only change jobs that cross a cetain threshold for the calculated timeout setting. here: onlyjobs that usually run longer than 10 minutes
		having ceiling(avg(timestampdiff(sql_tsi_minute, starttime, endtime))*1.5) > 10
		)as jobs
	,table
		(
		exec "SYSADMIN.changeJobParameters"(
			    "jobid" => jobs.jobid,
			    "runTimeout" => jobs.jobTimeoutSetting)
		) as changes
;;