param([switch]$a) 

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$inputFile = Join-Path $PSScriptRoot "status.txt"
$ignoreFile = Join-Path $PSScriptRoot "ignore.txt"

if ($a) {
    $outputFile = Join-Path $PSScriptRoot "cs2_stats.csv"
    Write-Host "Mode: APPENDING to cs2_stats.csv" -ForegroundColor Yellow
} else {
    $outputFile = Join-Path $PSScriptRoot "output.csv"
    Write-Host "Mode: WRITING to output.csv" -ForegroundColor Yellow
}

if (-not (Test-Path $inputFile)) {
    Write-Host "Error: status.txt not found!" -ForegroundColor Red
    return
}

# 1. Setup ignore list (Always ignore DemoRecorder + contents of ignore.txt)
$ignoreList = @("DemoRecorder")
if (Test-Path $ignoreFile) {
    $ignoreList += Get-Content $ignoreFile | ForEach-Object { $_.Trim() }
}

# 2. Regex to find player names
$pattern = "\[Client\]\s+\d+\s+[\d:BOT]+\s+\d+\s+\d+\s+active\s+\d+\s+'(.*?)'"
$content = Get-Content $inputFile -Raw
$matches = [regex]::Matches($content, $pattern)

if ($matches.Count -gt 0) {
    $addedCount = 0
    foreach ($match in $matches) {
        $playerName = $match.Groups[1].Value
        
        if ($ignoreList -contains $playerName) {
            Write-Host "Skipping ignored player: $playerName" -ForegroundColor Gray
            continue
        }

        # CSV Columns: game,match,steam_id,name,on_team,slur,n-word,politics,notes
        $csvLine = "cs2,,,""$playerName"",,,,,"
        Add-Content -Path $outputFile -Value $csvLine
        Write-Host "Added: $playerName" -ForegroundColor Green
        $addedCount++
    }

    # 3. Add an empty separator line after the last player of the game
    Add-Content -Path $outputFile -Value ",,,,,,,,"
    
    Write-Host "`nDone! Added $addedCount players and a separator line." -ForegroundColor Cyan
} else {
    Write-Host "No active players found." -ForegroundColor Yellow
}