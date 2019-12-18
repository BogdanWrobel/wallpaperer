$baseReg = "HKCU:Software"
$companyReg = "WrobelConsulting"
$appReg = "Wallpaperer"
$regPath = "${baseReg}\${companyReg}\${appReg}"

$regLat = "Latitude"
$regLon = "Longitude"
$regStamp = "Timestamp"
$regTheme = "Theme"

Export-ModuleMember -Variable $baseReg, $companyReg, $appReg, $regPath, $regLat, $regLon, $regStamp, $regTheme