-- find all users that are member of admin-role or super-admin-role
select *
from "SYSADMIN.UserRoles"
where roleName in ('admin-role', 'super-admin-role')
;;

-- list all roles that give explicit execute permissions to ds_file
select "role", "resource", "permission"
from "SYSADMIN.Permissions"
where lower("resource") = 'ds_file'
	and "permission" like '%E%'
;;
	
-- list all users belonging to roles that give explicit execute permissions to ds_file
select "r.userName", "role", "resource", "permission"
from "SYSADMIN.Permissions" as p
	inner join "SYSADMIN.UserRoles" as r on p.role = "r.roleName" 
where lower("resource") = 'ds_file'
	and "permission" like '%E%'
;;

-- remove all role asignments for t.berners-lee that are not connect-dv-role or file-only roles
select "roleName"
from "SYSADMIN.UserRoles"
	, table ( exec "SYSADMIN.deleteUserRole"(
        "user_name" => 't.berners-lee',
        "role_name" => "roleName"
    )) as a
where "userName" = 't.berners-lee'
	and "roleName" not in ('connect-dv-role', 'file-only')
;;