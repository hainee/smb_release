@echo off
rem SMB站点发布脚本——Hainee 2020-09
cls
TITLE SMB Projects Release Manager
cd %~dp0
set main_version=1.3.
set release_root_path=%~dp0
set smb_login_path=%release_root_path%..\smb_login\code\v1
set smb_main_path=%release_root_path%..\smb_main\code\v1
set dist_path=.\dist
set project_name=cn
set project_id=
set release_all_flag=0
set release_all_use_default_path=y
color 0a

:MENU
  echo ==================SMB Projects Release Manager========================
  echo Project will release to folder "%release_root_path%"
  echo SMB Login path = %smb_login_path%
  echo SMB Main path = %smb_main_path%
  echo.
  echo *Select a release item*
  ECHO.
  ECHO [1] Release SMB Login (Project Name:cn)
  ECHO [2] Release SMB Main  (Project Name:chat)
  ECHO [3] Release ALL  
  ECHO [4] Clear Files  
  ECHO.
  ECHO [8] Exit Script
  ECHO [9] Close Command Prompt
  ECHO.

  set /p id=Select Item = [1/2/3/4/8/9]:
  IF "%id%"=="1" GOTO ReleaseSMBLogin
  IF "%id%"=="2" GOTO ReleaseSMBMain
  IF "%id%"=="3" GOTO ReleaseAll
  IF "%id%"=="4" GOTO ClearFiles
  IF "%id%"=="8" GOTO QUIT
  IF "%id%"=="9" Exit
  cls
GOTO RETURNMENU

rem 清除发布目录
:ClearFiles
  set /p clear_project_folder=Clear all project files?[y/n]:
  if "%clear_project_folder%"=="y" (
    if exist %release_root_path%release rd %release_root_path%release /Q /S
    echo.
    echo All peoject files removed!
    echo.
    PAUSE
  )
GOTO RETURNMENU

rem 发布所有站点
:ReleaseAll
  set release_all_flag=1
  echo Use default path to release projects?
  set /p release_all_use_default_path=[y/n/x]:
  if "%release_all_use_default_path%"=="y" (
    echo Use default paths.
  ) else if "%release_all_use_default_path%"=="n" (
    echo Use input paths.
  ) else if "%release_all_use_default_path%"=="x" (
    GOTo RETURNMENU
  ) else (
    GOTO ReleaseAll
  )
  GOTO ReleaseSMBLogin
GOTo RETURNMENU

rem 发布指定的项目
:ReleaseProject
  git pull origin
  
  set cdn_path=%release_root_path%release\dist\
  set cdn_project_path=%cdn_path%%project_name%\
  set cdn_common_path=%cdn_path%common\
  echo.
  echo Project Name              = %project_name%
  echo Project Dist Path         = %dist_path%
  echo Release CDN Path          = %cdn_path%
  echo Release CDN Project Path  = %cdn_project_path%
  echo Release CDN Common Path   = %cdn_common_path%
  echo.
  if %release_all_flag%==0 (
    if "%project_id%"=="SMB Main" (
    for /f "delims=" %%i in (%release_root_path%version.js) do (set cur_version=%%i)&(goto CONFIRM_VERSION)
:CONFIRM_VERSION
    SET cur_version=%cur_version:~27,-1%
    SET old_small_version=%cur_version:~4,3%
    SET /a new_small_version=%old_small_version%+1
    SET version=
    SET /p version=Version[%main_version%%old_small_version% ^>^> %main_version%%new_small_version%]?:%main_version%
    if [%version%]==[] (
        SET version=%new_small_version%
    )
    ECHO New Version = %main_version%%version%
    )
:CONFIRM_RELEASE
    set /p confirm_release=Confirm release?[y/n]:
    if "%confirm_release%"=="n" (
      GOTO RETURNMENU
    ) else (
      echo.
      echo *******************************************************************************************
      echo                            Start release project %project_id%
      echo *******************************************************************************************
      echo.
      if "%project_id%"=="SMB Main" (
          ECHO window.SMB_CORE_VERSION = '%main_version%%version%'>%release_root_path%version.js
      )
    )
  )

  rem 创建不存在的文件夹
  if not exist %cdn_path% md %cdn_path%
  if not exist %cdn_project_path% md %cdn_project_path%
  if not exist %cdn_common_path% md %cdn_common_path%

  rem 复制项目的index.html到发布目录
  copy %dist_path%index.html %release_root_path%release\index.html.%project_name%
  echo.

  rem 复制项目静态资源到发布目录
  xcopy %dist_path%%project_name% %cdn_project_path% /s /y
  echo.

  rem 复制项目公共资源到发布目录
  xcopy %dist_path%common %cdn_common_path% /s /y

  rem 复制版本文件到发布目录
  ECHO.
  ECHO Copy Version.js
  copy %release_root_path%version.js %cdn_common_path%js\version.js

  if "%project_id%"=="SMB Main" (
      rem 删除help目录
      ECHO.
      ECHO Remove help folder
      rd /s/q %cdn_common_path%help
  )

  git commit -a -m "Auto Publish"
  git push origin

  rem 正在压缩dist
  ECHO.
  ECHO 正在压缩dist...
  7z a -tzip dist.zip "%dist_path%" -r -mx=5

  ECHO.
  ECHO *******************************************************************************************
  ECHO                            Project "%project_id%" release complete!
  ECHO *******************************************************************************************
  ECHO.

  if %release_all_flag%==0 (
    PAUSE
    GOTO RETURNMENU
  ) else if %release_all_flag%==1 (
    set release_all_flag=2
    GOTO ReleaseSMBMain
  ) else if %release_all_flag%==2 (
    set release_all_flag=0
    GOTO MENU
  )
  

rem 发布SMB Login站点
:ReleaseSMBLogin
  set default_path=
  set project_id=SMB Login
  if "%release_all_use_default_path%"=="n" (
    echo *Input %project_id% Project Path*
    echo Default %project_id% project path = %smb_login_path%
    set /p default_path=[Set %project_id% project path = ]:
  )
  
  if [%default_path%]==[] (
    echo Use default path.
  ) else (
    echo Use input path = %default_path%
    set smb_login_path=%default_path%
  )
  
  echo Current %project_id% project path = %smb_login_path%
  set dist_path=%smb_login_path%\dist\
  set project_name=cn
  GOTO ReleaseProject

rem 发布SMB Main站点
:ReleaseSMBMain
  set default_path=
  set project_id=SMB Main
  if "%release_all_use_default_path%"=="n" (
    echo *Input %project_id% Project Path*
    echo Default %project_id% project path = %smb_main_path%
    set /p default_path=[Set %project_id% project path = ]:
  )
  if [%default_path%]==[] (
    echo Use default path.
  ) else (
    echo Use input path = %default_path%
    set smb_main_path=%default_path%
  )
  
  echo Current %project_id% project path = %smb_main_path%
  set dist_path=%smb_main_path%\dist\
  set project_name=chat
  GOTO ReleaseProject

:RETURNMENU
cls
GOTO MENU

rem Exit Script
:QUIT