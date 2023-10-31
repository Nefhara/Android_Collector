@ECHO OFF
title ANDROID Extractor

:: ########################## MAIN ############################
:: ############################################################
:: Start of script and variables

setlocal 
echo [INFO] Starting ADB Extract Tool...

call :set_var
call :start_adb_server
call :check_device
call :set_path
call :info_collect
call :live_collect
call :package_manager
call :sd_card
call :info_sys
call :full_copy
call :adb_backup

:: PERMISSION REQUIRED
::call :user_data_extract

echo [*****************]
echo [INFO] Data collection completed
echo [*****************]


:: ####################### FUNCTION ###############################
:: ########## Function set_var - Definition of variables ##########
:: ################################################################
:set_var

:: generic var
set "VERSION=1.0 - 2023.08.08"	
set "ADB=.\adb.exe"

:: generic command var
set "SHELL_COMMAND=%ADB% shell"
set "BACKUP_COMMAND=%ADB% backup"
set "PULL_COMMAND=%ADB% pull"

EXIT /B 0


:: ######################################################################
:: ########## Function start_adb_server - Launching ADB server ##########
:: ######################################################################
:start_adb_server

echo [INFO] Starting ADB server
%ADB% kill-server
timeout /t 5
%ADB% start-server
echo [INFO] Waiting for USB connection validation on smartphone
pause 

EXIT /B 0


:: ############################################################
:: ########## Function check_device - Device control ##########
:: ############################################################
:check_device

echo [INFO] USB connection control
:: Android ID
for /f %%A in ('%SHELL_COMMAND% getprop ril.serialnumber') do set "ANDROID_SERIAL_NUMBER=%%A"
set "CLEANED_ANDROID_ID=%ANDROID_SERIAL_NUMBER:~0,20%"

EXIT /B 0


:: ####################################################################
:: ########## Function set_path - Definition of backup paths ##########
:: ####################################################################
:set_path

echo [INFO] Definition of backup paths

:: Generic paths
set "SPATH=%CLEANED_ANDROID_ID%"
MKDIR "%SPATH%"

:: Directories for device information
set "INFO_DIR=%SPATH%\info"
set "INFO_TXT_FILE=%INFO_DIR%\device_info.txt"
mkdir "%INFO_DIR%"

:: Directories for running live orders
set "LIVE_DIR=%SPATH%\live"
set "LIVE_LOG_FILE=%LIVE_DIR%\log_live_acquisition.txt"
mkdir %LIVE_DIR%

:: Directories for running the package manager
set "PM_DIR=%SPATH%\package_manager"
set "PM_LOG_FILE=%PM_DIR%\log_pm_acquisition.txt"
mkdir %PM_DIR%

:: Directories for DUMPSYS acquisition
set "DUMPSYS_DIR=%SPATH%\dumpsys"
set "DUMPSYS_LOG_FILE=%DUMPSYS_DIR%\log_dumpsys_acquisition.txt"
mkdir %DUMPSYS_DIR%
::set "DUMPSYS_DIR_APPOPS=%DUMPSYS_DIR%\appops"
::mkdir %DUMPSYS_DIR_APPOPS%

:: Directories for SDCARD acquisition
set "SDCARD_DIR=%SPATH%\sdcard"
set "SDCARD_LOG_FILE=%SDCARD_DIR%\log_sdcard_acquisition.txt"
mkdir %SDCARD_DIR%

:: Directories for SYSTEM acquisition
set "SYSTEM_DIR=%SPATH%\system"
set "SYSTEM_LOG_FILE=%SYSTEM_DIR%\log_system_acquisition.txt"
mkdir %SYSTEM_DIR%

:: Directories for 'private' image
set "BACKUP_DIR=%SPATH%\backup"
set "BACKUP_DIR_LOG=%BACKUP_DIR%\log_adb_backup.txt"
mkdir %BACKUP_DIR%

:: Directories for content providers
::set "CONTENTPROVIDER_DIR=%SPATH%\contentprovider"
::set "CONTENTPROVIDER_LOG_FILE=%CONTENTPROVIDER_DIR%\contentprovider.txt"
::mkdir %CONTENTPROVIDER_DIR%

EXIT /B 0


:: ####################################################################################
:: ########## Function info_collect - Collecting system hardware information ##########
:: ####################################################################################
:info_collect
echo [INFO] Start collecting system hardware information

%SHELL_COMMAND% getprop > %INFO_DIR%\getprop.txt"
%SHELL_COMMAND% settings list system > %INFO_DIR%\settings_system.txt"
%SHELL_COMMAND% settings list secure > %INFO_DIR%\settings_secure.txt"
%SHELL_COMMAND% settings list global > %INFO_DIR%\settings_global.txt"

for /f %%A in ('%SHELL_COMMAND% getprop ro.product.model') do set "PRODUCT=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.product.manufacturer') do set "MANUFACTURER=%%A"

echo [INFO] Dumping info from : %MANUFACTURER% %PRODUCT%  > %INFO_TXT_FILE%
echo [INFO] Dumping info from : %MANUFACTURER% %PRODUCT%

for /f %%A in ('%SHELL_COMMAND% settings get secure android_id') do set "ANDROID_ID=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.build.version.release') do set "ANDROID_VERSION=%%A"
for /f %%A in ('%SHELL_COMMAND% "service call iphonesubinfo 1 | cut -c 52-66 | tr -d '.[:space:]'"') do set "IMEI=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ril.product_code') do set "PRODUCT_CODE=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.product.device') do set "DEVICE=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.product.name') do set "NAME=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.chipname') do set "CHIPNAME=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.build.fingerprint') do set "FINGERPRINT=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.build.id') do set "BUILD_ID=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.boot.bootloader') do set "BOOTLOADER=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.build.version.security_patch') do set "SECURITY_PATCH=%%A"
for /f %%A in ('%SHELL_COMMAND% settings get secure bluetooth_address') do set "BLUETOOTH_MAC=%%A"
for /f %%A in ('%SHELL_COMMAND% settings get secure bluetooth_name') do set "BLUETOOTH_NAME=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop persist.sys.timezone') do set "TIMEZONE=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.csc.country_code') do set "COUNTRY_CODE=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop persist.sys.usb.config') do set "USB_CONFIGURATION=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop ro.crypto.state') do set "ENCRYPTION=%%A"
for /f %%A in ('%SHELL_COMMAND% getprop gsm.version.baseband') do set "BASEBAND_VERSION=%%A"

for /f "tokens=2-7 delims= " %%A in ('%SHELL_COMMAND% date') do (
	set "MONTH=%%A"
	set "DAY=%%B"
	set "TIME=%%C"
	set "TIMEZONE=%%D"
	set "YEAR=%%E")

set "ENCRYPTION_TYPE=none"
if not "%ENCRYPTION%"=="unencrypted" (
    for /F %%A in ('%ADB% shell getprop ro.crypto.type') do set "ENCRYPTION_TYPE=%%A"
)

echo [*] Android_id: %ANDROID_ID%  >> %INFO_TXT_FILE%
echo [*] Android Serial number: %ANDROID_SERIAL_NUMBER% >> %INFO_TXT_FILE%
echo [*] Android Serial number: %ANDROID_SERIAL_NUMBER%
echo [*] Android version: %ANDROID_VERSION% >> %INFO_TXT_FILE%
echo [*] IMEI : %IMEI% >> %INFO_TXT_FILE%
echo [*] IMEI : %IMEI%
echo [*] Product Code: %PRODUCT_CODE% >> %INFO_TXT_FILE%
echo [*] Product Device: %DEVICE% >> %INFO_TXT_FILE%
echo [*] Product Name: %NAME% >> %INFO_TXT_FILE%
echo [*] Chipname: %CHIPNAME% >> %INFO_TXT_FILE%
echo [*] Android fingerprint: %FINGERPRINT% >> %INFO_TXT_FILE%
echo [*] Build ID: %BUILD_ID% >> %INFO_TXT_FILE%
echo [*] Bootloader: %BOOTLOADER% >> %INFO_TXT_FILE%
echo [*] Baseband : %BASEBAND_VERSION% >> %INFO_TXT_FILE%
echo [*] Security Patch: %SECURITY_PATCH% >> %INFO_TXT_FILE%
echo [*] Bluetooth_address: %BLUETOOTH_MAC% >> %INFO_TXT_FILE%
echo [*] Bluetooth_name: %BLUETOOTH_NAME% >> %INFO_TXT_FILE%
echo [*] Timezone: %TIMEZONE% >> %INFO_TXT_FILE%
echo [*] Country: %COUNTRY_CODE% >> %INFO_TXT_FILE%
echo [*] Device Time: %DAY% %MONTH% %YEAR% - %TIME% (%TIMEZONE%) >> %INFO_TXT_FILE%
echo [*] USB Configuration: %USB_CONFIGURATION% >> %INFO_TXT_FILE%
echo [*] Encrypted: %ENCRYPTION% (%ENCRYPTION_TYPE%) >> %INFO_TXT_FILE%

echo [INFO] Collection completed
echo [*]

EXIT /B 0


:: ##############################################################################
:: ########## Function live_collect - Gathering additional information ##########
:: ##############################################################################
:live_collect
echo [INFO] Executing live commands on linux system

%SHELL_COMMAND% id > "%LIVE_DIR%\id.txt"
%SHELL_COMMAND% uname -a > "%LIVE_DIR%\uname-a.txt"
%SHELL_COMMAND% cat /proc/version > "%LIVE_DIR%\kernel_version.txt"
%SHELL_COMMAND% logcat -S -b all > "%LIVE_DIR%\logcat-S-b_all.txt"
%SHELL_COMMAND% logcat -d -b all V:* > "%LIVE_DIR%\logcat-d-b-all_V.txt"
%SHELL_COMMAND% printenv > "%LIVE_DIR%\printenv.txt"
%SHELL_COMMAND% cat /proc/partitions > "%LIVE_DIR%\partitions.txt"
%SHELL_COMMAND% df -ah > "%LIVE_DIR%\df_ah.txt"
%SHELL_COMMAND% mount > "%LIVE_DIR%\mount.txt"
%SHELL_COMMAND% ip address show wlan0 > "%LIVE_DIR%\ip_address.txt"
%SHELL_COMMAND% ifconfig -a > "%LIVE_DIR%\ifconfig.txt"
%SHELL_COMMAND% netstat -an > "%LIVE_DIR%\netstat.txt"
%SHELL_COMMAND% lsof > "%LIVE_DIR%\lsof.txt"
%SHELL_COMMAND% ps -ef > "%LIVE_DIR%\ps.txt"
%SHELL_COMMAND% cat /proc/sched_debug > "%LIVE_DIR%\sched_debug.txt"
%SHELL_COMMAND% sysctl -a > "%LIVE_DIR%\sysctl.txt" 2> "%LIVE_DIR%\sysctl_error_log.txt"
%SHELL_COMMAND% ime list > "%LIVE_DIR%\ime_list.txt"
%SHELL_COMMAND% service list > "%LIVE_DIR%\services.txt"

echo [INFO] Collection completed
echo [*]

EXIT /B 0


:: ###########################################################################
:: ########## Function package-manager - Collecting APK information ##########
:: ###########################################################################
:package_manager
echo [INFO] Start collecting APK information

%SHELL_COMMAND% pm get-max-users > "%PM_DIR%\pm_get_max_users.txt"
%SHELL_COMMAND% pm list users > "%PM_DIR%\pm_list_users.txt"
%SHELL_COMMAND% pm list features > "%PM_DIR%\pm_list_features.txt"
%SHELL_COMMAND% pm list permission-groups > "%PM_DIR%\pm_list_permission_groups.txt"
%SHELL_COMMAND% pm list libraries -f > "%PM_DIR%\pm_list_libraries-f.txt"
%SHELL_COMMAND% pm list packages -d > "%PM_DIR%\pm_list_packages-d.txt"
%SHELL_COMMAND% pm list packages -e > "%PM_DIR%\pm_list_packages-e.txt"
%SHELL_COMMAND% pm list packages -f -u > "%PM_DIR%\pm_list_packages-f.txt"
%SHELL_COMMAND% pm list permissions -f > "%PM_DIR%\pm_list_permissions-f.txt"
%SHELL_COMMAND% cat /data/system/uiderrors.txt > "%PM_DIR%\uiderrors.txt"

echo [INFO] Collection completed
echo [*]

EXIT /B 0


:: ####################################################
:: ########## Function sd_card - SDCARD Copy ##########
:: ####################################################
:sd_card
echo [INFO] Start collecting SD Card information

set "DEVICE_SDCARD=/sdcard"

%PULL_COMMAND% %DEVICE_SDCARD% %SPATH% >> "%SDCARD_LOG_FILE%" 2>&1

::hash calculation and archive creation to integrate

echo [INFO] Collection completed
echo [*]

EXIT /B 0


:: ############################################################################
:: ########## Function info_sys - Collecting live system information ##########
:: ############################################################################
:info_sys
echo [INFO] Start collecting system information

%SHELL_COMMAND% dumpsys > "%DUMPSYS_DIR%\dumpsys.txt" 2> "%DUMPSYS_DIR%\dumpsys_error_log.txt"
%SHELL_COMMAND% dumpsys -l > "%DUMPSYS_DIR%\dumpsys-l.txt"
%SHELL_COMMAND% dumpsys account > "%DUMPSYS_DIR%\dumpsys_account.txt" 
%SHELL_COMMAND% dumpsys appwidget > "%DUMPSYS_DIR%\dumpsys_appwidget.txt" 
%SHELL_COMMAND% dumpsys appops > "%DUMPSYS_DIR%\dumpsys_appops.txt"
%SHELL_COMMAND% dumpsys backup > "%DUMPSYS_DIR%\dumpsys_backup.txt"
%SHELL_COMMAND% dumpsys batterystats > "%DUMPSYS_DIR%\dumpsys_batterystats.txt"
%SHELL_COMMAND% dumpsys bluetooth_manager > "%DUMPSYS_DIR%\dumpsys_bluetooth_manager.txt"
%SHELL_COMMAND% dumpsys carrier_config > "%DUMPSYS_DIR%\dumpsys_carrier_config.txt"
%SHELL_COMMAND% dumpsys clipboard > "%DUMPSYS_DIR%\dumpsys_clipboard.txt"
%SHELL_COMMAND% dumpsys content > "%DUMPSYS_DIR%\dumpsys_content.txt"
%SHELL_COMMAND% dumpsys cpuinfo > "%DUMPSYS_DIR%\dumpsys_cpuinfo.txt"
%SHELL_COMMAND% dumpsys dbinfo > "%DUMPSYS_DIR%\dumpsys_dbinfo.txt "
%SHELL_COMMAND% dumpsys dbinfo -v > "%DUMPSYS_DIR%\dumpsys_dbinfo-v.txt "
%SHELL_COMMAND% dumpsys device_policy > "%DUMPSYS_DIR%\dumpsys_device_policy.txt"
%SHELL_COMMAND% dumpsys jobscheduler > "%DUMPSYS_DIR%\dumpsys_jobscheduler.txt"
%SHELL_COMMAND% dumpsys location > "%DUMPSYS_DIR%\dumpsys_location.txt"
%SHELL_COMMAND% dumpsys meminfo -a > "%DUMPSYS_DIR%\dumpsys_meminfo-a.txt"
%SHELL_COMMAND% dumpsys meminfo -a -c > "%DUMPSYS_DIR%\dumpsys_meminfo-a-c.txt"
%SHELL_COMMAND% dumpsys mount > "%DUMPSYS_DIR%\dumpsys_mount.txt"
%SHELL_COMMAND% dumpsys netstats detail > "%DUMPSYS_DIR%\dumpsys_netstats.txt"
%SHELL_COMMAND% dumpsys network_management > "%DUMPSYS_DIR%\dumpsys_network_management.txt"
%SHELL_COMMAND% dumpsys notification > "%DUMPSYS_DIR%\dumpsys_notification.txt"
%SHELL_COMMAND% dumpsys package > "%DUMPSYS_DIR%\dumpsys_package.txt"
%SHELL_COMMAND% dumpsys permission > "%DUMPSYS_DIR%\dumpsys_permission.txt"
%SHELL_COMMAND% dumpsys procstats --full-details > "%DUMPSYS_DIR%\dumpsys_procstats--full-details.txt"
%SHELL_COMMAND% dumpsys user > "%DUMPSYS_DIR%\dumpsys_user.txt"
%SHELL_COMMAND% dumpsys usb > "%DUMPSYS_DIR%\dumpsys_usb.txt"

%SHELL_COMMAND% telecom get-default-dialer > "%DUMPSYS_DIR%\telecom_get-default-dialer.txt"
%SHELL_COMMAND% telecom get-system-dialer > "%DUMPSYS_DIR%\telecom_get-system-dialer.txt"

:: ROOT right required ???
::for /f %%P in ('%SHELL_COMMAND% pm list packages') do (
::    	echo "[*] appops get 2000 %%P" && %SHELL_COMMAND% appops get %%P > "%DUMPSYS_DIR_APPOPS%\%%P_appops.txt")

echo [INFO] Collection completed
echo [*]

EXIT /B 0


:: ###############################################################
:: ########## Function full_copy - Full smartphone copy ##########
:: ###############################################################
:full_copy
echo [INFO] Start copying full system

set "EXCLUDE_FOLDER=proc dev"

for /f %%D in ('%SHELL_COMMAND% ls') do (
	if not "%%D"=="proc" (
		if not "%%D"=="dev" (
			if not "%%D"=="sdcard" (
				echo [INFO] Copying folder %%D
				%PULL_COMMAND% %%D %SYSTEM_DIR% >> "%SYSTEM_LOG_FILE%" 2>&1
			)
		)
	) 
)

::hash calculation and archive creation to integrate

echo [INFO] Copy completed
echo [*]

EXIT /B 0


:: ##################################################################
:: ########## Function adb_backup - Full smartphone backup ##########
:: ##################################################################
:adb_backup
echo [INFO] Start ADB Backup
echo [INFO] Default password : 12345

set "TMP_SCRIPT=tmp_script.bat"
set "BACKUP_PASSWORD=12345"

echo timeout /t 5 2>&1 >nul > %TMP_SCRIPT%
echo %SHELL_COMMAND% input text %BACKUP_PASSWORD% >> %TMP_SCRIPT%
echo timeout /t 2 2>&1 >nul >> %TMP_SCRIPT%
echo %SHELL_COMMAND% input tap 950 1800 >> %TMP_SCRIPT%
echo exit >> %TMP_SCRIPT%

start /MIN %TMP_SCRIPT%

%BACKUP_COMMAND% -all -system -keyvalue -apk -obb -f "%BACKUP_DIR%\backup.ab" >> %BACKUP_DIR_LOG% 2>&1 

start /MIN %TMP_SCRIPT%

%BACKUP_COMMAND% -shared -f "%BACKUP_DIR%\shared.ab" >> %BACKUP_DIR_LOG% 2>&1

del %TMP_SCRIPT%

echo [INFO] Backup completed
echo [*]

EXIT /B 0


:: #################################################################################
:: ########## Function user_data_extract - Collection of user information ##########
:: #################################################################################
:user_data_extract
echo [INFO] Start user data exctraction

echo [INFO] SMS
%SHELL_COMMAND% content query --uri content://sms > %CONTENTPROVIDER_DIR%\sms.txt >> %CONTENTPROVIDER_LOG_FILE%

echo [INFO] MMS
%SHELL_COMMAND% content query --uri content://mms > %CONTENTPROVIDER_DIR%\mms.txt >> %CONTENTPROVIDER_LOG_FILE%

echo [INFO] CONTACT
%SHELL_COMMAND% content query --uri content://contacts > %CONTENTPROVIDER_DIR%\contact.txt >> %CONTENTPROVIDER_LOG_FILE%

echo [INFO] CALL HISTORY
%SHELL_COMMAND% content query --uri content://call_log/calls > %CONTENTPROVIDER_DIR%\call.txt >> %CONTENTPROVIDER_LOG_FILE%

echo [INFO] GPS
%PULL_COMMAND% /data/misc/location/gps/gps.conf %CONTENTPROVIDER_DIR%/gps.conf
%PULL_COMMAND% /data/misc/location/gps/gps.log %CONTENTPROVIDER_DIR%/gps.log

echo [INFO] CALENDAR
%PULL_COMMAND% /data/data/com.android.providers.calendar/databases/calendar.db %CONTENTPROVIDER_DIR%/calendar.db

echo [INFO] Collection completed
echo [*]

EXIT /B 0

:: #####################################################
endlocal  
:: End of script and variables
:: ####################### END #########################