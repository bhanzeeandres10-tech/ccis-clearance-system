@echo off
setlocal
set "CCIS_WEB_DIR=%~dp0build\web"

if not exist "%CCIS_WEB_DIR%\index.html" (
  echo The CCIS CLEARANCE web build was not found.
  echo Expected: %CCIS_WEB_DIR%\index.html
  pause
  exit /b 1
)

where py >nul 2>nul
if errorlevel 1 (
  echo Python is required to start the local CCIS CLEARANCE preview.
  echo Install Python from python.org, then run this file again.
  pause
  exit /b 1
)

rem Start the server in the background only when port 8080 is not already in use.
powershell -NoProfile -Command "$listener = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue; if (-not $listener) { Start-Process -WindowStyle Hidden -FilePath py -ArgumentList '-m','http.server','8080','--directory','%CCIS_WEB_DIR%' }"
timeout /t 2 /nobreak >nul
start "" http://127.0.0.1:8080/

echo CCIS CLEARANCE is open at http://127.0.0.1:8080/
echo The local server runs in the background while the website is open.
pause
