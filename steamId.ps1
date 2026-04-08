# steamProfile.ps1
# Usage: .\steamProfile.ps1 "https://steamcommunity.com/id/TiggerLover/"

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Url
)

$Url = $Url.Trim().TrimEnd('/')
$steamId = "Unknown"

try {
    if ($Url -match "steamid64\.net/profile/(\d+)") {
        # Case 1: Share URL - Extract ID from URL path
        $steamId = $Matches[1]
    }
    elseif ($Url -match "steamcommunity\.com/profiles/(\d+)") {
        # Case 2: Standard Profile URL
        $steamId = $Matches[1]
    }
    elseif ($Url -match "steamcommunity\.com/id/([^/]+)") {
        # Case 3: Custom Vanity URL - Resolve via Steam XML
        $vanityName = $Matches[1]
        $xmlUrl = "https://steamcommunity.com/id/$vanityName/?xml=1"
        
        $webRequest = Invoke-WebRequest -Uri $xmlUrl -UseBasicParsing -ErrorAction Stop
        if ($webRequest.Content -match "<steamID64>(\d+)</steamID64>") {
            $steamId = $Matches[1]
        }
    }
}
catch {
    Write-Error "Failed to resolve URL: $($_.Exception.Message)"
    exit 1
}

# Output only the ID to the console
Write-Output $steamId