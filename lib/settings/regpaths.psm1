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
}

function getConfigNames {
    return $wallpapererKeys
}

Export-ModuleMember -Function getConfigNames