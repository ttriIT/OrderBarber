# SQL Server Connection Test Script
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host " SQL SERVER CONNECTION TEST" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Test different connection scenarios
$testConfigs = @(
    @{
        Name = "SQL Server LocalDB"
        ConnectionString = "Server=(localdb)\MSSQLLocalDB;Database=master;Trusted_Connection=True;TrustServerCertificate=True"
    },
    @{
        Name = "SQL Server Express (Named Instance)"
        ConnectionString = "Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=True;TrustServerCertificate=True"
    },
    @{
        Name = "SQL Server (Default Instance)"
        ConnectionString = "Server=localhost;Database=master;Trusted_Connection=True;TrustServerCertificate=True"
    }
)

$successCount = 0
$totalTests = $testConfigs.Count

foreach ($config in $testConfigs) {
    Write-Host "Testing: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Connection String: $($config.ConnectionString)" -ForegroundColor Gray
    
    try {
        # Load SQL Client assembly
        Add-Type -AssemblyName System.Data
        
        $connection = New-Object System.Data.SqlClient.SqlConnection($config.ConnectionString)
        $connection.Open()
        
        # Get server info
        $command = $connection.CreateCommand()
        $command.CommandText = @"
SELECT 
    @@VERSION as ServerVersion,
    @@SERVERNAME as ServerName,
    SERVERPROPERTY('ProductVersion') as ProductVersion,
    SERVERPROPERTY('Edition') as Edition
"@
        
        $reader = $command.ExecuteReader()
        if ($reader.Read()) {
            Write-Host "  ? SUCCESS!" -ForegroundColor Green
            Write-Host "  Server Name: $($reader['ServerName'])" -ForegroundColor Green
            Write-Host "  Edition: $($reader['Edition'])" -ForegroundColor Green
            Write-Host "  Product Version: $($reader['ProductVersion'])" -ForegroundColor Green
            $successCount++
        }
        $reader.Close()
        $connection.Close()
        
    } catch {
        Write-Host "  ? FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host " SUMMARY" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Failed: $($totalTests - $successCount)" -ForegroundColor Red
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "? At least one SQL Server instance is accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "RECOMMENDED CONNECTION STRING:" -ForegroundColor Yellow
    
    # Determine best connection string
    foreach ($config in $testConfigs) {
        try {
            $connection = New-Object System.Data.SqlClient.SqlConnection($config.ConnectionString)
            $connection.Open()
            $connection.Close()
            
            # Found working connection
            $recommendedConnectionString = $config.ConnectionString -replace "Database=master", "Database=BarberBookingDB"
            Write-Host $recommendedConnectionString -ForegroundColor Green
            
            Write-Host ""
            Write-Host "Update your appsettings.json with:" -ForegroundColor Yellow
            Write-Host '  "ConnectionStrings": {' -ForegroundColor White
            Write-Host "    `"DefaultConnection`": `"$recommendedConnectionString`"" -ForegroundColor White
            Write-Host '  }' -ForegroundColor White
            break
        } catch {
            # Try next config
        }
    }
} else {
    Write-Host "? No SQL Server instance found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "TROUBLESHOOTING STEPS:" -ForegroundColor Yellow
    Write-Host "1. Check if SQL Server is installed:" -ForegroundColor White
    Write-Host "   - Run: Get-Service -Name MSSQL*" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Install SQL Server Express (if not installed):" -ForegroundColor White
    Write-Host "   - Download from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Or use SQL Server LocalDB (lightweight):" -ForegroundColor White
    Write-Host "   - Run: sqllocaldb create MSSQLLocalDB" -ForegroundColor Gray
    Write-Host "   - Run: sqllocaldb start MSSQLLocalDB" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Check Windows Services:" -ForegroundColor White
    Write-Host "   - Press Win+R, type 'services.msc'" -ForegroundColor Gray
    Write-Host "   - Find 'SQL Server' services and start them" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
