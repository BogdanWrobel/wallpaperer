Import-Module .\lib\settings\regpaths.psm1

$cfgKeys = getConfigNames

function set-StoredLocation([double]$latitude, [double]$longitude) {
    Write-Host "Saving location for further use"
    if (!(Test-Path -Path "${cfgKeys.baseReg}\${cfgKeys.companyReg}")) {
        New-Item -Path "${cfgKeys.baseReg}\${cfgKeys.companyReg}"
    }
    if (!(Test-Path -Path "${cfgKeys.regPath}")) {
        New-Item -Path "${cfgKeys.regPath}"
    } 

    $ts = get-Timestamp

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regLat -value $latitude -Force
    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regLon -value $longitude -Force
    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regStamp -value $ts -Force
}

function get-StoredLocation {
    Write-Host "Attempting to retrieve saved location."
    $value = "" | Select-Object -Property latitude,longitude,timestamp,autoupdate
    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and
            $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regLat) -and
            $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regLon) -and
            $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regStamp)) {
           
            $lat = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regLat
            $lon = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regLon
            $value.latitude = ([double]::Parse($lat))
            $value.longitude = ([double]::Parse($lon))
            $value.timestamp = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regStamp
        }
    }
    return $value
}

function isAutoUpdate {
    if (Test-Path -Path $cfgKeys.regPath) {
        $properties = Get-ItemProperty -Path $cfgKeys.regPath 
        if ($properties -and $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regAutoUpdate)) {
            return [bool](Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regAutoUpdate)
        } else {
            return $false
        }
    }
    return $false
}

Export-ModuleMember -Function get-StoredLocation, set-StoredLocation, isAutoUpdate