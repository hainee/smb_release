@echo off
rem SMB站点发布脚本——Hainee 2020-09
cls
TITLE SMB Projects Release Manager

set release_root_path=%~dp0
set smb_login_path=..\smb_login\code\v1
set smb_main_path=..\smb_main\code\v1
set dist_path=.\dist
set project_name=cn
set project_id=
set release_all_flag=0
set release_all_use_default_path=y

:MENU
color 0a
echo ==================SMB Projects Release Manager========================
echo Project will release to folder "%release_root_path%"

echo.
echo *Select a release item*
ECHO.
ECHO [1] Release SMB Login (Project Name:cn)
ECHO [2] Release SMB Main  (Project Name:chat)
ECHO [3] Release ALL  
ECHO.
ECHO [8] Exit Script
ECHO [9] Close Command Prompt
ECHO.

set /p id=Select Item = [1/2/3/8/9]:
IF "%id%"=="1" GOTO ReleaseSMBLogin
IF "%id%"=="2" GOTO ReleaseSMBMain
IF "%id%"=="3" GOTO ReleaseAll
IF "%id%"=="8" GOTO QUIT
IF "%id%"=="9" Exit
cls
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
  set release_project_path=%release_root_path%%project_name%\
  set cdn_path=%release_root_path%cdn\dist\
  set cdn_project_path=%cdn_path%%project_name%\
  set cdn_common_path=%cdn_path%common\
  echo.
  echo Project Name              = %project_name%
  echo Project Dist Path         = %dist_path%
  echo Release Project Path      = %release_project_path%
  echo Release CDN Path          = %cdn_path%
  echo Release CDN Project Path  = %cdn_project_path%
  echo Release CDN Common Path   = %cdn_common_path%
  echo.
  if %release_all_flag%==0 (
:CONFIRM_RELEASE
    set /p confirm_release=Confirm release?[y/n]:
    if "%confirm_release%"=="n" (
      GOTO RETURNMENU
    ) else if "%confirm_release%"=="y" (
      echo.
      echo *******************************************************************************************
      echo                            Start release project %project_id%
      echo *******************************************************************************************
      echo.
    ) else (
      GOTO CONFIRM_RELEASE
    )
  )

  rem 创建不存在的文件夹
  if not exist %cdn_path% md %cdn_path%
  if not exist %release_project_path% md %release_project_path%
  if not exist %cdn_project_path% md %cdn_project_path%
  if not exist %cdn_common_path% md %cdn_common_path%

  rem 复制项目的index.html到发布目录
  copy %dist_path%index.html %release_project_path%
  echo.

  rem 复制项目静态资源到发布目录
  xcopy %dist_path%%project_name% %cdn_project_path% /s /y
  echo.

  rem 复制项目公共资源到发布目录
  xcopy %dist_path%common %cdn_common_path% /s /y

  echo.
  echo *******************************************************************************************
  echo                            Project "%project_id%" release complete!
  echo *******************************************************************************************
  echo.

  if %release_all_flag%==0 (
    PAUSE
    GOTO RETURNMENU
  ) else if %release_all_flag%==1 (
    set release_all_flag=2
    GOTO ReleaseSMBMain
  ) else if %release_all_flag%==2 (
    set release_all_flag=0
    PAUSE
    GOTO RETURNMENU
  )
  

rem 发布SMB Login站点
:ReleaseSMBLogin
  rem 获取SMB Login项目的发布参数
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
  rem 获取SMB Main项目的发布参数
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