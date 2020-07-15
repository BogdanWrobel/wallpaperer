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

function isWhiteTaskbarEnabled {
    $cfgKeys = getConfigNames

    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regWhiteTaskbar)) {
            return [System.Convert]::ToBoolean($properties.$($cfgKeys.regWhiteTaskbar))
        } else {
            return $false
        }
    }
    return $false
}

function setWhiteTaskbarEnabled([bool]$enable) {
    $cfgKeys = getConfigNames

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regWhiteTaskbar -value $enable -Force
}

function isKeepTheme {
    $cfgKeys = getConfigNames

    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regKeepTheme)) {
            return [System.Convert]::ToBoolean($properties.$($cfgKeys.regKeepTheme))
        } else {
            return $false
        }
    }
    return $false76
}

function setKeepTheme([bool]$enable) {
    $cfgKeys = getConfigNames

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regKeepTheme -value $enable -Force
}

function isAutoBrightnessEnabled {
    $cfgKeys = getConfigNames

    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regBrightness)) {
            return [System.Convert]::ToBoolean($properties.$($cfgKeys.regBrightness))
        } else {
            return $false
        }
    }
    return $false
}

function setAutoBrightnessEnabled([bool]$enable) {
    $cfgKeys = getConfigNames

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regBrightness -value $enable -Force
}

Export-ModuleMember -Function getSavedThemePath, setSavedThemePath, isWhiteTaskbarEnabled, setWhiteTaskbarEnabled, isAutoBrightnessEnabled, setAutoBrightnessEnabled, isKeepTheme, setKeepTheme