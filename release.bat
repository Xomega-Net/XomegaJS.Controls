@echo off

SET VER=%1
SET NUGET_PATH=.nuget\NuGet.exe
SET NUGET_VERSION=latest
SET CACHED_NUGET=%LocalAppData%\NuGet\nuget.%NUGET_VERSION%.exe

IF '%VER%'=='' (
  echo Please use the following format: release.bat {version}
  goto end
)

IF NOT EXIST .nuget md .nuget
IF NOT EXIST %NUGET_PATH% (
  IF NOT EXIST %CACHED_NUGET% (
    echo Downloading latest version of NuGet.exe...
    IF NOT EXIST %LocalAppData%\NuGet ( 
      md %LocalAppData%\NuGet
    )
    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/%NUGET_VERSION%/nuget.exe' -OutFile '%CACHED_NUGET%'"
  )

  copy %CACHED_NUGET% %NUGET_PATH% > nul
)

IF EXIST "pkg\content\" rd /q /s "pkg\content"
xcopy /q /s /i "Content" "pkg\content\Content" >nul
IF EXIST "pkg\XomegaJS.Controls.%VER%" rd /q /s "pkg\XomegaJS.Controls.%VER%"
md "pkg\XomegaJS.Controls.%VER%"
md "pkg\content\Scripts"
copy "Scripts\xomega-controls.js" "pkg\content\Scripts\xomega-controls-%VER%.js" >nul

@powershell (Get-Content -raw PackageJS.nuspec) -replace '{version}', '%VER%' > pkg\Package.nuspec

%NUGET_PATH% pack "pkg\Package.nuspec" -OutputDirectory "pkg\XomegaJS.Controls.%VER%"

rd /s /q pkg\content
del pkg\Package.nuspec

IF EXIST "pkg\XomegaJS.Controls.Typed.%VER%" rd /q /s "pkg\XomegaJS.Controls.Typed.%VER%"
md "pkg\XomegaJS.Controls.Typed.%VER%"
xcopy /q /s /i "Scripts\typings" "pkg\content\Scripts\typings" >nul

@powershell (Get-Content -raw PackageTS.nuspec) -replace '{version}', '%VER%' > pkg\Package.nuspec

%NUGET_PATH% pack "pkg\Package.nuspec" -OutputDirectory "pkg\XomegaJS.Controls.Typed.%VER%"

rd /s /q pkg\content
del pkg\Package.nuspec

:end