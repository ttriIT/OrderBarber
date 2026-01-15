# Test PostgreSQL Connection Script
# File: TestConnection.ps1

param(
    [string]$Server = "ManHenry",
    [int]$Port = 5432,
    [string]$Database = "BarberBookingDB",
    [string]$Username = "postgres",
    [string]$Password = ""
)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "PostgreSQL Connection Test" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Function to test connection
function Test-PostgreSQLConnection {
    param(
        [string]$ConnectionString
    )
    
    try {
        Add-Type -Path "C:\Program Files\PostgreSQL\15\Npgsql.dll" -ErrorAction Stop
        
        $conn = New-Object Npgsql.NpgsqlConnection($ConnectionString)
        $conn.Open()
        
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT version();"
        $version = $cmd.ExecuteScalar()
        
        Write-Host "? CONNECTION SUCCESSFUL!" -ForegroundColor Green
        Write-Host ""
        Write-Host "PostgreSQL Version:" -ForegroundColor Yellow
        Write-Host $version -ForegroundColor White
        Write-Host ""
        
        # Test database
        $cmd.CommandText = "SELECT current_database();"
        $currentDb = $cmd.ExecuteScalar()
        Write-Host "Current Database: $currentDb" -ForegroundColor Yellow
        
        # Test user
        $cmd.CommandText = "SELECT current_user;"
        $currentUser = $cmd.ExecuteScalar()
        Write-Host "Current User: $currentUser" -ForegroundColor Yellow
        
        # Count tables
        $cmd.CommandText = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
        $tableCount = $cmd.ExecuteScalar()
        Write-Host "Total Tables: $tableCount" -ForegroundColor Yellow
        
        $conn.Close()
        return $true
    }
    catch {
        Write-Host "? CONNECTION FAILED!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error Message:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor White
        Write-Host ""
        return $false
    }
}

# Get password if not provided
if ([string]::IsNullOrEmpty($Password)) {
    $SecurePassword = Read-Host "Enter PostgreSQL password for user '$Username'" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# Build connection string
$connectionString = "Host=$Server;Port=$Port;Database=$Database;Username=$Username;Password=$Password;Timeout=10;"

Write-Host "Testing connection with:" -ForegroundColor Cyan
Write-Host "  Server   : $Server" -ForegroundColor White
Write-Host "  Port     : $Port" -ForegroundColor White
Write-Host "  Database : $Database" -ForegroundColor White
Write-Host "  Username : $Username" -ForegroundColor White
Write-Host "  Password : " -NoNewline -ForegroundColor White
Write-Host "********" -ForegroundColor Gray
Write-Host ""

# Test using psql command if available
Write-Host "Method 1: Testing with psql command..." -ForegroundColor Yellow
$psqlPath = "C:\Program Files\PostgreSQL\15\bin\psql.exe"
if (Test-Path $psqlPath) {
    $env:PGPASSWORD = $Password
    $output = & $psqlPath -h $Server -p $Port -U $Username -d $Database -c "SELECT 'Connection OK' as status;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? psql connection successful" -ForegroundColor Green
    } else {
        Write-Host "? psql connection failed" -ForegroundColor Red
        Write-Host $output -ForegroundColor White
    }
    $env:PGPASSWORD = $null
} else {
    Write-Host "??  psql not found at standard location" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Method 2: Testing with .NET Npgsql..." -ForegroundColor Yellow

# Try to load Npgsql from NuGet packages
$npgsqlDll = Get-ChildItem -Path "C:\Users\$env:USERNAME\.nuget\packages\npgsql\" -Filter "Npgsql.dll" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($npgsqlDll) {
    Add-Type -Path $npgsqlDll.FullName
    Test-PostgreSQLConnection -ConnectionString $connectionString
} else {
    Write-Host "??  Npgsql.dll not found in NuGet cache" -ForegroundColor Yellow
    Write-Host "   Run 'dotnet restore' first" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Connection String for appsettings.json:" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$safeConnectionString = "Host=$Server;Port=$Port;Database=$Database;Username=$Username;Password=YOUR_PASSWORD_HERE;Pooling=true;MinPoolSize=1;MaxPoolSize=20;ConnectionLifetime=15;CommandTimeout=30;Timeout=15;"
Write-Host $safeConnectionString -ForegroundColor Green
Write-Host ""

Write-Host "??  Remember to replace YOUR_PASSWORD_HERE with your actual password!" -ForegroundColor Yellow
Write-Host ""
