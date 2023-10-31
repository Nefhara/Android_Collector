# -Android_Collector
BAT script android artefact collector.

# -How to launch it
This is a standard bat script, you need to run it with inside ADB folder :

  - On the smartphone, enable android developer options in app settings,
  - On the smartphone, enable USB debugging,
  - On the computer, copy adb_XXX.bat script inside a standard ADB.exe folder,
  - On the command prompt : `adb_extract_SAMSUNG_S7_EDGE_Android_8.bat`

  ![ALT](/Referentiel/launch_1.png)

  ![ALT](/Referentiel/launch_2.png)

# -Functions
  - **start_adb_server** : use adb.exe application to access android.
  - **check_device** : search for connected smartphones.
  - **info_collect** : collection of smartphone system information (os version, serial number, MAC, etc.).
  - **live_collect** : launching linux command on smartphone (id, ifconfig, etc.).
  - **package_manager** : collection of smartphone package information (apk, rights, etc.).
  - **sd_card** : copy all SDCARD data with user right.
  - **info_sys** : collection of smartphone system usage information (memory, process, etc.).
  - **full_copy** : copy all SYSTEM data with user right.
  - **adb_backup** : creating a full phone backup via android utility.

# -Result
  - Folder creation at the root of the script with the serial number of the smartphone as the name.
  - This folder contains the results of the script functions as well as the backups.

# -To do list
  - Add banner and help information.
  - Create a menu with the function choice to launch.
  - Modify backup function to include an automatic pixel size.
  - Add error handling.
