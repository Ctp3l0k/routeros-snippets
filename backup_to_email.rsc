# Скрипт не мой. Взял его из конфигов одной из работ и добавил переменные:
# в оригинале логин-пароль-ящик были указаны прямо в скрипте, а еще письма приходили
# на тот же ящик, с которого отправлялись. А, еще добавил экспорт с compact.
# Наверное, переменные нужно было указывать в начале скрипта, но ¯\_(ツ)_/¯
# И вообще, нужно переходить на специализированный софт и/или хранение конфига в гите.

{
:log info "Starting backup script";
:local sysname [/system identity get name];
:local sysver [/system package get system version];
:delay 2;
:foreach i in=[/file find] do={:if ([:typeof [:find [/file get $i name] "$sysname-backup-"]]!="nil") do={/file remove $i}};
:delay 2;
:local smtpserv [:resolve "smtp.yandex.ru"];
:local fromemail email@yandex.ru;
:local toemail email@yandex.ru;
:local pass MegaPassword;
:local backupfile ("$sysname-backup-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . ".backup");
/system backup save name=$backupfile;
:delay 2;
/tool e-mail send from="<$fromemail>" to=$toemail server=$smtpserv port=587 user=$fromemail password=$pass start-tls=yes file=$backupfile subject=("$sysname full backup (" . [/system clock get date] . ")") body=("RouterOS version: $sysver\nTime and Date: " . [/system clock get time] . " " . [/system clock get date]);
:delay 5;
:local exportfile ("$sysname-backup-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . ".rsc");
/export verbose file=$exportfile;
:delay 2;
/tool e-mail send from="<$fromemail>" to=$toemail server=$smtpserv port=587 user=$fromemail password=$pass start-tls=yes file=$exportfile subject=("$sysname script backup (" . [/system clock get date] . ")") body=("RouterOS version: $sysver\nTime and Date: " . [/system clock get time] . " " . [/system clock get date]);
:delay 5;
:local exportfilecompact ("$sysname-backup-compact-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . ".rsc");
/export compact file=$exportfilecompact;
:delay 2;
/tool e-mail send from="<$fromemail>" to=$toemail server=$smtpserv port=587 user=$fromemail password=$pass start-tls=yes file=$exportfilecompact subject=("$sysname script compact backup (" . [/system clock get date] . ")") body=("RouterOS version: $sysver\nTime and Date: " . [/system clock get time] . " " . [/system clock get date]);
:delay 5;
:log info "Backup is complete and send";
}
