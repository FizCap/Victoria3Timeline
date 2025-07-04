# PowerShell script to fix basic technology dependencies in country history

# Define essential prerequisite technologies that are commonly missing
$tech_fixes = @{
    # If country has banking, ensure it has currency_standards
    "banking" = @("currency_standards")
    
    # If country has currency_standards, ensure it has international_trade and centralization
    "currency_standards" = @("international_trade", "centralization")
    
    # If country has international_trade, ensure it has tech_bureaucracy
    "international_trade" = @("tech_bureaucracy")
    
    # If country has centralization, ensure it has tech_bureaucracy
    "centralization" = @("tech_bureaucracy")
    
    # If country has tech_bureaucracy, ensure it has urbanization
    "tech_bureaucracy" = @("urbanization")
    
    # If country has democracy, ensure it has rationalism
    "democracy" = @("rationalism")
    
    # If country has mass_communication, ensure it has democracy
    "mass_communication" = @("democracy")
    
    # If country has medical_degrees, ensure it has academia
    "medical_degrees" = @("academia")
    
    # If country has empiricism, ensure it has academia
    "empiricism" = @("academia")
    
    # If country has romanticism, ensure it has academia
    "romanticism" = @("academia")
    
    # If country has law_enforcement, ensure it has tech_bureaucracy and urban_planning
    "law_enforcement" = @("tech_bureaucracy", "urban_planning")
    
    # If country has urban_planning, ensure it has urbanization
    "urban_planning" = @("urbanization")
    
    # If country has stock_exchange, ensure it has international_trade
    "stock_exchange" = @("international_trade")
    
    # If country has colonization, ensure it has international_relations
    "colonization" = @("international_relations")
    
    # If country has international_relations, ensure it has tech_bureaucracy
    "international_relations" = @("tech_bureaucracy")
    
    # Military tech dependencies
    "line_infantry" = @("standing_army")
    "military_drill" = @("standing_army")
    "napoleonic_warfare" = @("military_drill")
    "army_reserves" = @("line_infantry")
    "mandatory_service" = @("line_infantry")
    
    # Naval tech dependencies
    "drydocks" = @("admiralty")
    "paddle_steamer" = @("admiralty")
    "admiralty" = @("navigation")
}

# Read the countries file
$filePath = 'c:\Users\Aweso\Documents\Paradox Interactive\Victoria 3\mod\Victoria3Timeline\common\history\countries\99_converted_countries.txt'
Write-Host "Reading file: $filePath"

$content = Get-Content $filePath -Raw
$newContent = $content

# Function to get all techs for a country
function Get-CountryTechs {
    param([string]$countryBlock)
    
    $techs = @()
    $matches = [regex]::Matches($countryBlock, "add_technology_researched = ([a-zA-Z_0-9]+)")
    foreach ($match in $matches) {
        $techs += $match.Groups[1].Value
    }
    return $techs
}

# Function to add missing prerequisites to a country block
function Add-MissingPrerequisites {
    param(
        [string]$countryBlock,
        [string]$countryTag
    )
    
    $existingTechs = Get-CountryTechs $countryBlock
    $missingTechs = @()
    
    # Check each existing tech for missing prerequisites
    foreach ($tech in $existingTechs) {
        if ($tech_fixes.ContainsKey($tech)) {
            foreach ($prerequisite in $tech_fixes[$tech]) {
                if ($prerequisite -notin $existingTechs -and $prerequisite -notin $missingTechs) {
                    $missingTechs += $prerequisite
                    Write-Host "  Adding missing prerequisite '$prerequisite' for '$tech' in $countryTag"
                }
            }
        }
    }
    
    # Add missing techs to the country block
    $result = $countryBlock
    foreach ($missingTech in $missingTechs) {
        # Find where to insert the tech (after the country tag line)
        if ($result -match "(c:[A-Z0-9]+ = \{)") {
            $insertion = "`$1`n`t`tadd_technology_researched = $missingTech"
            $result = $result -replace "(c:[A-Z0-9]+ = \{)", $insertion
        }
    }
    
    return $result
}

# Process each country that has technologies
$countryPattern = '(c:[A-Z0-9]+ = \{[^}]*add_technology_researched[^}]*\})'
$matches = [regex]::Matches($content, $countryPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

$processedCount = 0
foreach ($match in $matches) {
    $countryBlock = $match.Value
    $countryTag = ""
    
    if ($countryBlock -match '(c:[A-Z0-9]+)') {
        $countryTag = $matches[1]
    }
    
    Write-Host "Processing $countryTag..."
    $updatedBlock = Add-MissingPrerequisites $countryBlock $countryTag
    
    if ($updatedBlock -ne $countryBlock) {
        $newContent = $newContent -replace [regex]::Escape($countryBlock), $updatedBlock
        $processedCount++
    }
}

# Write the updated content back
Set-Content -Path $filePath -Value $newContent -NoNewline
Write-Host "Technology dependency fixes complete!"
Write-Host "Countries processed: $processedCount"
