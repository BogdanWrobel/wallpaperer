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
}

function getConfigNames {
    ensureRegPathExists
    return $wallpapererKeys
}

function ensureRegPathExists {
    if (!(Test-Path -Path "${wallpapererKeys.baseReg}\${wallpapererKeys.companyReg}")) {
        New-Item -Path "${wallpapererKeys.baseReg}\${wallpapererKeys.companyReg}"
    }
    if (!(Test-Path -Path $wallpapererKeys.regPath)) {
        New-Item -Path $wallpapererKeys.regPath
    } 
}

Export-ModuleMember -Function getConfigNames, ensureRegPathExists