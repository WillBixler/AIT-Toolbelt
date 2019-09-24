function Get-Definitions {
    
    $path = "$($PSScriptRoot)\BloatwareDefinitions.json"
    return Get-Content -Path $path | ConvertFrom-Json
    
}

function Sort-Definitions {
    param (
        $definitions
    )

    $definitions.Bloatware = $definitions.Bloatware | Sort-Object
    $definitions.Ignore = $definitions.Ignore | Sort-Object
    
    return $definitions
}

function Add-BloatwareDefinition {
    param (
        $definitions,
        $newDefinition
    )

    $definitions.Bloatware += $newDefinition
    $definitions = Sort-Definitions $definitions

    return $definitions
}

function Save-Definitions {
    param (
        $definitions
    )

    $path = "$($PSScriptRoot)\BloatwareDefinitions.json"
    $definitions | ConvertTo-Json | Out-File $path
    
}

$definitions = Get-Definitions
$newDefinition = Read-Host -Prompt "New bloatware definition"
$definitions = Add-BloatwareDefinition -definitions $definitions -newDefinition $newDefinition
Save-Definitions $definitions
Write-Host "Definition added!"
Pause