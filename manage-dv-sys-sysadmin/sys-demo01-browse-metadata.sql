-- find all tables that have a column that is named like 'modified'
select "schemaName", "tableName", "name"
from "SYS.Columns"
where lower("name") like '%modified%'
;;

-- find all procedure input parameters that are of type clob
select "schemaName", "procedureName", "name"
from "SYS.ProcedureParams"
where "DataType" = 'clob'
	and "Type" = 'In'
;;

-- find all tables, views and procedures that contain the word 'data'
-- note that SYS.Tables contains tables AND virtual views
select "schemaName", "Name", "Type"
from "SYS.Tables"
where lower("Name") like '%data%'
union all
select "schemaName", "Name", 'Procedure' as "type"
from "SYS.Procedures" 
where lower("Name") like '%data%'
;;