$wallpapererKeys = @{
    baseReg = "HKCU:Software"
    companyReg = "WrobelConsulting"
    appReg = "Wallpaperer"
    regPath = "HKCU:Software\WrobelConsulting\Wallpaperer"
    regLat = "Latitude"
    regLon = "Longitude"
    regStamp = "Timestamp"
    regTheme = "Theme"
    regAutoUpdate = "AutoUpdate"
    regWhiteTaskbar = "WhiteTaskbar"  
    regBrightness = "AdjustBrightness"
    regKeepTheme = "PreserveColorTheme"
}

function getConfigNames {
    ensureRegPathExists
    return $wallpapererKeys
}

function ensureExists($path) {
    Write-Host ("Testing for " + $path)
    if (!(Test-Path -Path $path)) {
        Write-Host ($path + " does not exist, creating.")
        New-Item -Path $path
    }
}

function ensureRegPathExists {
    ensureExists -path ($wallpapererKeys.baseReg + "\" + $wallpapererKeys.companyReg)
    ensureExists -path $wallpapererKeys.regPath
}

Export-ModuleMember -Function getConfigNames, ensureRegPathExists