@echo off
REM Quick PostgreSQL Connection Test
REM File: test-connection.bat

echo ============================================
echo PostgreSQL Connection Test
echo ============================================
echo.

set SERVER=ManHenry
set PORT=5432
set DATABASE=BarberBookingDB
set USERNAME=postgres

echo Server   : %SERVER%
echo Port     : %PORT%
echo Database : %DATABASE%
echo Username : %USERNAME%
echo.

REM Test connection using psql
set /p PASSWORD="Enter PostgreSQL password: "

echo.
echo Testing connection...
echo.

"C:\Program Files\PostgreSQL\15\bin\psql.exe" -h %SERVER% -p %PORT% -U %USERNAME% -d %DATABASE% -c "SELECT 'Connection successful!' as status, version();"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo SUCCESS! Connection to database is working
    echo ============================================
    echo.
    echo Your connection string:
    echo Host=%SERVER%;Port=%PORT%;Database=%DATABASE%;Username=%USERNAME%;Password=YOUR_PASSWORD;Pooling=true;MinPoolSize=1;MaxPoolSize=20;
    echo.
) else (
    echo.
    echo ============================================
    echo FAILED! Could not connect to database
    echo ============================================
    echo.
    echo Possible issues:
    echo 1. PostgreSQL service is not running
    echo 2. Incorrect password
    echo 3. Server name or database name is wrong
    echo 4. Firewall blocking connection
    echo.
)

pause
