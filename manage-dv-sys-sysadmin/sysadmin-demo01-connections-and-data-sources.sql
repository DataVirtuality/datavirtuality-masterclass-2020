-- Find failed data sources
select "name", "translator" "creator"
from "SYSADMIN.DataSources"
where "failed" = true
;;

-- List all data sources of the same type
select "name"
from "SYSADMIN.DataSources"
where "translator" = 'postgresql'
;;

select "name"
from "SYSADMIN.Connections"
where "template" = 'ws'
;;

-- How to find all available translators and [cli} templates
select *
from "SYSADMIN.Translators"
;;

select "name", "translator"
from "SYSADMIN.CliTemplates"
;;

-- List all connections that have the same connection information
select "name", "template"
from "SYSADMIN.Connections"
where "userName" is null
;;

-- List all data sources added within the last X days or by the a specific user
select "name", "translator"
from "SYSADMIN.DataSources"
where creationDate > timestampadd(sql_tsi_day, -7, curdate())
;;

-- Refresh a data source’s metadata for re-reading available tables and views from the source
exec "SYSADMIN.refreshDataSource"(
    "name" => 'dwh')
;;