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
		
		-- if the data source cannot be refresh with success then we log the error message to the server.log file
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

end
;;