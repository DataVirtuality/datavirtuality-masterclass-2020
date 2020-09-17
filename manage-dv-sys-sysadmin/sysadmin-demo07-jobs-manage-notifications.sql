-- note that email notifications only work with SMTP settings configured on DV side
-- check the current status of emil notifications
select *
from "SYSADMIN.JobEmailNotifications"
;;

-- add/update email notification for a job
exec "SYSADMIN.enableJobEmailNotification"(
    "jobIds" => '8',
    "jobStatuses" => 'SUCCESS',
    "recipients" => 'martin.lutzemann@datavirtuality.de'
);;

-- disable email notifiaction for a job
exec "SYSADMIN.disableJobEmailNotification"(
    "jobIds" => '8'
);;


-- add/update global email notification
exec "SYSADMIN.enableJobEmailNotification"(
    "jobIds" => '*',
    "jobStatuses" => 'FAILED',
    "recipients" => 'martin.lutzemann@datavirtuality.de'
);;

-- disable global email notifiaction
exec "SYSADMIN.disableJobEmailNotification"(
    "jobIds" => '*'
);;

