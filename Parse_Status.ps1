param([switch]$a) # Define the -a flag

# Get the folder where this script is located
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$inputFile = Join-Path $PSScriptRoot "status.txt"
$ignoreFile = Join-Path $PSScriptRoot "ignore.txt"

# Decide which output file to use based on the -a flag
if ($a) {
    $outputFile = Join-Path $PSScriptRoot "cs2_stats.csv"
    Write-Host "Mode: APPENDING to cs2_stats.csv" -ForegroundColor Yellow
} else {
    $outputFile = Join-Path $PSScriptRoot "output.csv"
    Write-Host "Mode: WRITING to output.csv" -ForegroundColor Yellow
}

# 1. Check if status.txt exists
if (-not (Test-Path $inputFile)) {
    Write-Host "Error: status.txt not found!" -ForegroundColor Red
    return
}

# 2. Load the ignore list
$ignoreList = @()
if (Test-Path $ignoreFile) {
    $ignoreList = Get-Content $ignoreFile | ForEach-Object { $_.Trim() }
}

# 3. Regex to find player names
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

        # CSV Format: game,match,steam_id,name,on_team,slur,n-word,politics,notes
        $csvLine = "cs2,,,""$playerName"",,,,,"
        Add-Content -Path $outputFile -Value $csvLine
        Write-Host "Added: $playerName" -ForegroundColor Green
        $addedCount++
    }
    Write-Host "`nDone! Added $addedCount players to $(Split-Path $outputFile -Leaf)." -ForegroundColor Cyan
} else {
    Write-Host "No active players found in status.txt." -ForegroundColor Yellow
}