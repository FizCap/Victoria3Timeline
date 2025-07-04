# PowerShell script to organize technologies alphabetically in country history

# Read the countries file
$filePath = 'c:\Users\Aweso\Documents\Paradox Interactive\Victoria 3\mod\Victoria3Timeline\common\history\countries\99_converted_countries.txt'
Write-Host "Reading file: $filePath"

$content = Get-Content $filePath -Raw

# Function to organize technologies alphabetically within a country block
function Organize-CountryTechs {
    param([string]$countryBlock)
    
    # Split the block into lines
    $lines = $countryBlock -split "`n"
    
    # Separate tech lines from other lines
    $techLines = @()
    $otherLines = @()
    
    foreach ($line in $lines) {
        if ($line -match "^\s*add_technology_researched = ") {
            $techLines += $line
        } else {
            $otherLines += $line
        }
    }
    
    # Sort tech lines alphabetically
    $techLines = $techLines | Sort-Object
    
    # Reconstruct the country block
    $result = @()
    $addedTechs = $false
    
    foreach ($line in $otherLines) {
        if ($line -match "c:[A-Z0-9]+ = \{" -and $techLines.Count -gt 0 -and -not $addedTechs) {
            $result += $line
            $result += $techLines
            $addedTechs = $true
        } elseif ($line -notmatch "^\s*add_technology_researched = ") {
            $result += $line
        }
    }
    
    return ($result -join "`n")
}

# Process each country that has technologies
$countryPattern = '(c:[A-Z0-9]+ = \{[^}]*add_technology_researched[^}]*\})'
$matches = [regex]::Matches($content, $countryPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

$newContent = $content
$processedCount = 0

foreach ($match in $matches) {
    $countryBlock = $match.Value
    $countryTag = ""
    
    if ($countryBlock -match '(c:[A-Z0-9]+)') {
        $countryTag = $matches[1]
    }
    
    $organizedBlock = Organize-CountryTechs $countryBlock
    
    if ($organizedBlock -ne $countryBlock) {
        $newContent = $newContent -replace [regex]::Escape($countryBlock), $organizedBlock
        $processedCount++
    }
}

# Write the organized content back
Set-Content -Path $filePath -Value $newContent -NoNewline
Write-Host "Technology organization complete!"
Write-Host "Countries processed: $processedCount"
