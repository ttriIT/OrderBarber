@echo off
echo ========================================
echo  SQL SERVER CONNECTION TEST
echo ========================================
echo.

REM Test SQL Server LocalDB
echo [1] Testing SQL Server LocalDB...
sqllocaldb info MSSQLLocalDB >nul 2>&1
if %errorlevel% equ 0 (
    echo    - LocalDB instance exists
    sqllocaldb info MSSQLLocalDB | findstr "State: Running" >nul 2>&1
    if %errorlevel% equ 0 (
        echo    - Status: RUNNING
    ) else (
        echo    - Status: STOPPED - Starting...
        sqllocaldb start MSSQLLocalDB
    )
) else (
    echo    - LocalDB not found
)

echo.
echo [2] Testing SQL Server Services...
sc query MSSQLSERVER >nul 2>&1
if %errorlevel% equ 0 (
    echo    - MSSQLSERVER service found
    sc query MSSQLSERVER | findstr "RUNNING" >nul 2>&1
    if %errorlevel% equ 0 (
        echo    - Status: RUNNING
    ) else (
        echo    - Status: NOT RUNNING
    )
) else (
    sc query "MSSQL$SQLEXPRESS" >nul 2>&1
    if %errorlevel% equ 0 (
        echo    - SQL Server Express found
        sc query "MSSQL$SQLEXPRESS" | findstr "RUNNING" >nul 2>&1
        if %errorlevel% equ 0 (
            echo    - Status: RUNNING
        ) else (
            echo    - Status: NOT RUNNING
        )
    ) else (
        echo    - No SQL Server service found
    )
)

echo.
echo [3] Running PowerShell connection test...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0TestSqlConnection.ps1"

echo.
echo ========================================
echo Test completed!
echo ========================================
pause
