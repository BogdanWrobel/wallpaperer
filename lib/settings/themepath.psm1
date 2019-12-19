Import-Module -Name .\lib\settings\regpaths.psm1

function get-SavedThemePath([string]$basePath) {
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

Export-ModuleMember -Function get-SavedThemePath