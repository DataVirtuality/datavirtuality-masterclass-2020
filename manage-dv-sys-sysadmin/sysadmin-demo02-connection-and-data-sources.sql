-- exported sample data source to build the procedure from
EXEC SYSADMIN.createtConnection(
	"name" => 'ds_ms_aw'
	, "jbossCLITemplateName" => 'mssql'
	, "connectionOrResourceAdapterProperties" => 'db=AdventureWorks,port=1433,user-name=sa,host=localhost'
	, "encryptedProperties" => 'password=cjzreSqR3TA0pxl99/JdQw==') ;;
EXEC SYSADMIN.createDataSource(
	"name" => 'ds_ms_aw'
	, "translator" => 'sqlserver'
	, "modelProperties" => 'importer.tableTypes="TABLE,VIEW",importer.schemaPattern=Sales,importer.importIndexes=TRUE,importer.useFullSchemaName=FALSE'
	, "translatorProperties" => 'SupportsOrderByString=false'
	, "encryptedModelProperties" => ''
	, "encryptedTranslatorProperties" => '') 
;;
	

-- create easy-to-use procedure
-- note that we move the password from encrypted properties to 'regular' properties as we expect the user will call the procedure with the password in cleartext
create virtual procedure helpers.addMsSqlDataSource
(
	alias string,
	host string,
	port integer,
	username string,
	password string,
	database string,
	schemas string
)
returns
(
	returnState string
)
as
begin
declare string returnState;
	begin
	begin
		exec SYSADMIN.createConnection(
			"name" => alias
			, "jbossCLITemplateName" => 'mssql'
			, "connectionOrResourceAdapterProperties" => 'db=' || database || ',port=' || port || ',user-name=' || username || ',password=' || password || ',host=' || host
			, "encryptedProperties" => '') ;
			
		exec SYSADMIN.createDataSource(
			"name" => alias
			, "translator" => 'sqlserver'
			, "modelProperties" => 'importer.tableTypes="TABLE,VIEW",importer.schemaPattern="' || schemas || '",importer.importIndexes=TRUE,importer.useFullSchemaName=FALSE'
			, "translatorProperties" => 'SupportsOrderByString=false'
			, "encryptedModelProperties" => ''
			, "encryptedTranslatorProperties" => '') ;
			
		returnState = 'success';
	end
	-- if the block above fails then it is likely that the connection was created but not the data source
	-- hence, we remove the connection to return to a clean Data Virtuality
	exception e
	begin
		exec "SYSADMIN.removeConnection"("name" => alias);
		returnState = 'failed';
	end
	end

select returnState;
end
;;

-- call the procedure
exec "helpers.addMsSqlDataSource"(
    "alias" => 'ms_sql',
    "host" => 'localhost',
    "port" => 1433,
    "username" => 'sa',
    "password" => 'Passwort123',
    "database" => 'AdventureWorks',
    "schemas" => 'Sales,Person'
)
;;