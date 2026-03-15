# Get the folder where this script is located
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$inputFile = Join-Path $PSScriptRoot "status.txt"
$ignoreFile = Join-Path $PSScriptRoot "ignore.txt"
$outputFile = Join-Path $PSScriptRoot "output.csv"

# 1. Check if status.txt exists
if (-not (Test-Path $inputFile)) {
    Write-Host "Error: status.txt not found!" -ForegroundColor Red
    return
}

# 2. Load the ignore list (if it exists)
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
        
        # Check if player is in the ignore list
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
    Write-Host "`nDone! Added $addedCount players to output.csv." -ForegroundColor Cyan
} else {
    Write-Host "No active players found in status.txt." -ForegroundColor Yellow
}