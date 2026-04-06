param([switch]$a) 

# Get folder locations
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$inputFile = Join-Path $PSScriptRoot "status.txt"
$ignoreFile = Join-Path $PSScriptRoot "ignore.txt"

# Decide output mode
if ($a) {
    $outputFile = Join-Path $PSScriptRoot "game_stats.csv"
    Write-Host "Mode: APPENDING to game_stats.csv" -ForegroundColor Yellow
} else {
    $outputFile = Join-Path $PSScriptRoot "output.csv"
    Write-Host "Mode: WRITING to output.csv" -ForegroundColor Yellow
}

if (-not (Test-Path $inputFile)) {
    Write-Host "Error: status.txt not found!" -ForegroundColor Red
    return
}

# 1. Date and Time generation for the new columns
$currentDate = Get-Date -Format "yyyy-MM-dd"
$currentTime = Get-Date -Format "HH:mm"

# 2. Setup ignore list
$ignoreList = @("DemoRecorder")
if (Test-Path $ignoreFile) {
    $ignoreList += Get-Content $ignoreFile | ForEach-Object { $_.Trim() }
}

# 3. Regex to find player names
$pattern = "\[Client\]\s+\d+\s+[\d:BOT]+\s+\d+\s+\d+\s+active\s+\d+\s+'(.*?)'"
$content = Get-Content $inputFile -Raw
$matches = [regex]::Matches($content, $pattern)

if ($matches.Count -gt 0) {
    
    # 4. ROBUST NEWLINE CHECK
    # Check if the file exists and if the last line is missing a newline character
    if (Test-Path $outputFile) {
        $fileText = [System.IO.File]::ReadAllText($outputFile)
        if ($fileText.Length -gt 0 -and -not $fileText.EndsWith("`n")) {
            [System.IO.File]::AppendAllText($outputFile, "`r`n")
            Write-Host "Fixed missing newline at the end of the file." -ForegroundColor DarkGray
        }
    }

    $addedCount = 0
    foreach ($match in $matches) {
        $playerName = $match.Groups[1].Value
        
        if ($ignoreList -contains $playerName) {
            Write-Host "Skipping ignored player: $playerName" -ForegroundColor Gray
            continue
        }

        # 5. NEW COLUMN FORMAT
        # Columns: date,time,game,player,player_id,on_team,slur,anti_black,antisemitic,facist,notes
        # This requires exactly 10 commas to separate the 11 columns.
        $csvLine = "$currentDate,$currentTime,cs2,""$playerName"",,,,,,,"
        
        Add-Content -Path $outputFile -Value $csvLine
        Write-Host "Added: $playerName" -ForegroundColor Green
        $addedCount++
    }

    # 6. Add an empty separator line (10 commas for 11 empty columns)
    Add-Content -Path $outputFile -Value ",,,,,,,,,,"
    
    Write-Host "`nDone! Added $addedCount players and a separator line." -ForegroundColor Cyan
} else {
    Write-Host "No active players found." -ForegroundColor Yellow
}