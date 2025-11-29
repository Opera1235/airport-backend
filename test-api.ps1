# Airport Backend API Test Script
# Usage: Run .\test-api.ps1 in PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Airport Backend API Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000/api"
$testResults = @()
$testId = $null

function Test-API {
    param(
        [string]$TestName,
        [string]$Method = "GET",
        [string]$Uri,
        [object]$Body = $null,
        [string]$ExpectedStatus = "200"
    )
    
    Write-Host "Test: $TestName" -ForegroundColor Yellow
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "  [PASS]" -ForegroundColor Green
        return @{ Success = $true; Response = $response }
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "  [PASS] (Expected error: $statusCode)" -ForegroundColor Green
            return @{ Success = $true; Response = $null }
        } else {
            Write-Host "  [FAIL]: $($_.Exception.Message)" -ForegroundColor Red
            return @{ Success = $false; Error = $_.Exception.Message }
        }
    }
}

# 1. Health Check
Write-Host "1. Health Check Test" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/health" -Uri "$baseUrl/health"
$testResults += @{ Test = "Health Check"; Result = $result.Success }

# 2. Get All Flights
Write-Host "`n2. Get All Flights Test" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights" -Uri "$baseUrl/flights"
if ($result.Success) {
    $flightCount = if ($result.Response -is [Array]) { $result.Response.Count } else { 1 }
    Write-Host "  Found $flightCount flights" -ForegroundColor Gray
}
$testResults += @{ Test = "Get All Flights"; Result = $result.Success }

# 3. Get Single Flight
Write-Host "`n3. Get Single Flight Test" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights/1" -Uri "$baseUrl/flights/1"
$testResults += @{ Test = "Get Single Flight"; Result = $result.Success }

# 4. Test Non-existent Flight
Write-Host "`n4. Test Non-existent Flight (Should return 404)" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights/99999" -Uri "$baseUrl/flights/99999" -ExpectedStatus "404"
$testResults += @{ Test = "Non-existent Flight (404)"; Result = $result.Success }

# 5. Filter Test - By Type
Write-Host "`n5. Filter Test - By Type" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights?type=Departure" -Uri "$baseUrl/flights?type=Departure"
if ($result.Success -and $result.Response) {
    $count = if ($result.Response -is [Array]) { $result.Response.Count } else { 1 }
    Write-Host "  Found $count Departure flights" -ForegroundColor Gray
}
$testResults += @{ Test = "Filter by Type"; Result = $result.Success }

# 6. Filter Test - By Airline
Write-Host "`n6. Filter Test - By Airline" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights?airline=EVA Air" -Uri "$baseUrl/flights?airline=EVA Air"
$testResults += @{ Test = "Filter by Airline"; Result = $result.Success }

# 7. Search Test - Flight Number
Write-Host "`n7. Search Test - Flight Number" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights?q=BR101" -Uri "$baseUrl/flights?q=BR101"
$testResults += @{ Test = "Search by Flight Number"; Result = $result.Success }

# 8. Sort Test
Write-Host "`n8. Sort Test" -ForegroundColor Cyan
$result = Test-API -TestName "GET /api/flights?sortBy=scheduledTime&order=asc" -Uri "$baseUrl/flights?sortBy=scheduledTime&order=asc"
$testResults += @{ Test = "Sort"; Result = $result.Success }

# 9. Create New Flight
Write-Host "`n9. Create New Flight Test" -ForegroundColor Cyan
$newFlight = @{
    flightNumber = "TEST$(Get-Random -Minimum 100 -Maximum 999)"
    airline = "Test Airlines"
    type = "Departure"
    origin = "TPE"
    destination = "NRT"
    scheduledTime = (Get-Date).AddDays(1).ToString("yyyy-MM-ddTHH:mm:ssZ")
    gate = "A1"
    status = "On Time"
}

$result = Test-API -TestName "POST /api/flights" -Uri "$baseUrl/flights" -Method "POST" -Body $newFlight
if ($result.Success -and $result.Response) {
    $testId = $result.Response.id
    Write-Host "  Created flight ID: $testId" -ForegroundColor Gray
}
$testResults += @{ Test = "Create Flight"; Result = $result.Success }

# 10. Update Flight
if ($testId) {
    Write-Host "`n10. Update Flight Test" -ForegroundColor Cyan
    $updateFlight = $newFlight.Clone()
    $updateFlight.status = "Delayed"
    $updateFlight.gate = "A2"
    
    $result = Test-API -TestName "PUT /api/flights/$testId" -Uri "$baseUrl/flights/$testId" -Method "PUT" -Body $updateFlight
    $testResults += @{ Test = "Update Flight"; Result = $result.Success }
    
    # 11. Delete Flight
    Write-Host "`n11. Delete Flight Test" -ForegroundColor Cyan
    $result = Test-API -TestName "DELETE /api/flights/$testId" -Uri "$baseUrl/flights/$testId" -Method "DELETE"
    $testResults += @{ Test = "Delete Flight"; Result = $result.Success }
} else {
    Write-Host "`n10-11. Skip update and delete tests (create failed)" -ForegroundColor Yellow
    $testResults += @{ Test = "Update Flight"; Result = $false }
    $testResults += @{ Test = "Delete Flight"; Result = $false }
}

# 12. Test Invalid Data Validation
Write-Host "`n12. Data Validation Test (Should return error)" -ForegroundColor Cyan
$invalidFlight = @{
    airline = "Test Airlines"
    # Missing required field flightNumber
}
$result = Test-API -TestName "POST /api/flights (invalid data)" -Uri "$baseUrl/flights" -Method "POST" -Body $invalidFlight -ExpectedStatus "400"
$testResults += @{ Test = "Data Validation"; Result = $result.Success }

# Test Results Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passed = ($testResults | Where-Object { $_.Result -eq $true }).Count
$total = $testResults.Count

foreach ($test in $testResults) {
    $status = if ($test.Result) { "[PASS]" } else { "[FAIL]" }
    $color = if ($test.Result) { "Green" } else { "Red" }
    Write-Host "$status $($test.Test)" -ForegroundColor $color
}

Write-Host "`nTotal: $passed / $total passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host ""

if ($passed -eq $total) {
    Write-Host "[SUCCESS] All tests passed!" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Some tests failed, please check if backend service is running properly" -ForegroundColor Yellow
}
