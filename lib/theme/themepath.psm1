Import-Module -Name .\lib\regconfig\regpaths.psm1

function getSavedThemePath([string]$basePath) {
    $cfgKeys = getConfigNames
    $theme = "${basePath}\themes\theme_catalina.json"
    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and
            $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regTheme)) {
            $theme = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regTheme
        }
    }
    return $theme
}

function setSavedThemePath([string]$themePath) {
    $cfgKeys = getConfigNames

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regTheme -value $themePath -Force
}

Export-ModuleMember -Function getSavedThemePath, setSavedThemePath