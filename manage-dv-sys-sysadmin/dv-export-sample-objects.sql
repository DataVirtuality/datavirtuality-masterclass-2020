EXEC SYSADMIN.createVirtualSchema("name" => 'helpers') ;;

-- add a sample procedure (solving quadratic equations) to schema "views"
create virtual procedure "views.solveQE"
(
	"a" double
	,"b" double
	,"c" double
)
returns
(
	"solution1" double
	,"solution2" double
)
as
begin

select (-b + sqrt(power(b,2) - 4*a*c))/(2*a) as "solution1"
		, (-b - sqrt(power(b,2) - 4*a*c))/(2*a) as "solution2";
end ;;

create virtual procedure helpers.dropSchmaByName
(
	"shemaName" string
)
as
begin

exec "SYSADMIN.dropVirtualSchema"(
	"id" => (select "id"
			from "SYSADMIN.VirtualSchemas"
			where "name" = "shemaName"
			)
	 );
end ;;

create virtual procedure helpers.startJobById
(
	"jobId" biginteger
)
as
begin
					
exec "SYSADMIN.createSchedule"(
	    "jobId" => jobId,
	    "type" => 'ONCE',
	    "startDelay" => 0,
	    "enabled" => true
);

end ;;

create virtual procedure helpers.startJobByDescription
(
	"jobDescription" string
)
as
begin

declare biginteger jobId = (select id
							from "SYSADMIN.ScheduleJobs" 
							where "description" = "jobDescription"
							);
					
exec "SYSADMIN.createSchedule"(
	    "jobId" => jobId,
	    "type" => 'ONCE',
	    "startDelay" => 0,
	    "enabled" => true
);
end ;;

create virtual procedure helpers.refreshDataSourceNoFail
(
	"dsName" string
)
as
begin

	begin	
		exec "SYSADMIN.refreshDataSource"(
	        "name" => dsName
	    );	
	end
	
	exception e
	begin
		exec "SYSADMIN.logMsg"(
	        "level" => 'INFO',
	        "context" => 'CUSTOM.OPERATIONS.REFRESHFAILEDDATASOURCES',
	        "msg" => 'Unable to refresh the datasource ' || dsName || 'because of the following error:' || chr(13)
	        			||  CAST(e.chain as string)
	    );
	end
end ;;

create virtual procedure helpers.refreshFailedDataSources()
as
begin
declare string dsName;

loop on (select "name"
		from "SYSADMIN.DataSources" 
		where "failed" = true) as cur
	begin
		begin
		dsName = cur.name;
		
		exec "SYSADMIN.refreshDataSource"(
	        "name" => dsName
	    );
		
		end
		
		exception e
		begin
			exec "SYSADMIN.logMsg"(
	            "level" => 'INFO',
	            "context" => 'CUSTOM.OPERATIONS.REFRESHFAILEDDATASOURCES',
	            "msg" => 'Unable to refresh the datasource ' || dsName || 'because of the following error:' || chr(13)
	            			||  CAST(e.chain as string)
	        );
		end
	end

end ;;

create virtual procedure helpers.refreshFailedDataSourcesAlternative()
as
begin

select 'done'
from "SYSADMIN.DataSources" as ds
	, table (exec helpers.refreshDataSourceNoFail ("ds.name")) as a
where "failed" = true;

end ;;