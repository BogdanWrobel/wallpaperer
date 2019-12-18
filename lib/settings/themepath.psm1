Import-Module -Name .\lib\settings\regpaths.psm1

function get-SavedThemePath {
    $theme = "themes\theme_catalina.json"
    if (Test-Path -Path $regPath) {
        $properties = Get-ItemProperty -Path $regPath 
        if ($properties -and
            $null -ne (Get-Member -InputObject $properties -Name $regTheme)) {
            $theme = Get-ItemPropertyValue -Path $regPath -Name $regTheme
        }
    }
    return $theme
}

Export-ModuleMember -Function get-SavedThemePath