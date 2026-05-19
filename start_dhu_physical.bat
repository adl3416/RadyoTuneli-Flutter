@echo off
setlocal

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "DHU=%LOCALAPPDATA%\Android\Sdk\extras\google\auto\desktop-head-unit.exe"
if "%DEVICE%"=="" set "DEVICE=auto"

if not exist "%ADB%" (
  echo [ERROR] adb not found: %ADB%
  exit /b 1
)

if not exist "%DHU%" (
  echo [ERROR] desktop-head-unit.exe not found: %DHU%
  exit /b 1
)

echo [1/3] Checking device...
if /I "%DEVICE%"=="auto" (
  for /f "tokens=1,2" %%A in ('"%ADB%" devices') do (
    if "%%B"=="device" (
      set "DEVICE=%%A"
      goto :device_found
    )
  )
  echo [ERROR] No authorized adb device found.
  "%ADB%" devices
  echo Unlock phone and allow USB debugging, then retry.
  exit /b 1
) else (
  "%ADB%" devices | findstr /R /C:"%DEVICE%.*device" >nul
  if errorlevel 1 (
    echo [ERROR] Device %DEVICE% not connected.
    echo Connect phone and enable USB debugging, then retry.
    exit /b 1
  )
)

:device_found
echo [INFO] Using detected device: %DEVICE%

echo [2/3] Setting ADB forward tcp:5277...
"%ADB%" forward tcp:5277 tcp:5277
if errorlevel 1 (
  echo [ERROR] Failed to set adb forward.
  exit /b 1
)

echo [3/3] Preparing Android Auto on phone...
"%ADB%" -s %DEVICE% shell am start -n com.google.android.projection.gearhead/.frx.SetupActivity >nul 2>&1
"%ADB%" -s %DEVICE% shell am start -n com.google.android.projection.gearhead/.companion.settings.DefaultSettingsActivity >nul 2>&1

echo [4/4] Starting DHU (auto-reconnect mode)...

:loop
"%DHU%"
echo [INFO] DHU exited. Reconnecting in 2 seconds...
timeout /t 2 /nobreak >nul
"%ADB%" forward tcp:5277 tcp:5277 >nul 2>&1
goto loop
