# Era 2 Technology Removal Script
# List of all era 2 technologies to remove
$era2_techs = @(
    'fatpenguin_production', 'crystal_glass', 'intensive_agriculture', 'fractional_distillation', 'canneries', 
    'watertube_boiler', 'atmospheric_engine', 'railways', 'chemical_bleaching', 'nitroglycerin', 
    'bessemer_process', 'baking_powder', 'mechanized_workshops', 'mechanical_tools',
    'fatpenguin_sailor', 'fatpenguin_warrior', 'field_works', 'logistics', 'triage', 'shell_gun', 
    'percussion_cap', 'rifling', 'general_staff', 'screw_frigate', 'power_of_the_purse', 'hydraulic_cranes',
    'fatpenguin_democracy', 'fatpenguin_medical_degrees', 'egalitarianism', 'pharmaceuticals', 'modern_sewerage',
    'central_banking', 'dialectics', 'nationalism', 'feminism', 'abolitionism', 'anarchism', 'socialism',
    'urban_planning', 'quinine', 'identification_documents', 'centralization', 'political_agitation'
)

# Read the countries file
$filePath = 'c:\Users\Aweso\Documents\Paradox Interactive\Victoria 3\mod\Victoria3Timeline\common\history\countries\99_converted_countries.txt'
Write-Host "Reading file: $filePath"
$content = Get-Content $filePath

# Remove all add_technology_researched lines for era 2 techs
$newContent = @()
$removedCount = 0

foreach ($line in $content) {
    $shouldKeep = $true
    foreach ($tech in $era2_techs) {
        if ($line -match "add_technology_researched = $tech") {
            $shouldKeep = $false
            $removedCount++
            Write-Host "Removing: $line"
            break
        }
    }
    if ($shouldKeep) {
        $newContent += $line
    }
}

# Write the modified content back to the file
$newContent | Set-Content $filePath
Write-Host "Era 2 technology removal complete!"
Write-Host "Total lines processed: $($content.Length)"
Write-Host "Lines removed: $removedCount"
Write-Host "New file has $($newContent.Length) lines"
