Import-Module .\lib\settings\regpaths.psm1
Import-Module .\lib\time\time.psm1

function setStoredLocation([double]$latitude, [double]$longitude) {
    Write-Host "Saving location for further use"
    $cfgKeys = getConfigNames

    $ts = getTimestamp

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regLat -value $latitude -Force
    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regLon -value $longitude -Force
    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regStamp -value $ts -Force
}

function getStoredLocation {
    Write-Host "Attempting to retrieve saved location."
    $cfgKeys = getConfigNames

    $value = "" | Select-Object -Property latitude,longitude,timestamp,autoupdate
    $properties = Get-ItemProperty -Path $cfgKeys.regPath 
    if ($null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regLat) -and
        $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regLon) -and
        $null -ne (Get-Member -InputObject $properties -Name $cfgKeys.regStamp)) {
        
        $lat = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regLat
        $lon = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regLon
        $value.latitude = ([double]::Parse($lat))
        $value.longitude = ([double]::Parse($lon))
        $value.timestamp = Get-ItemPropertyValue -Path $cfgKeys.regPath -Name $cfgKeys.regStamp
    }
    
    return $value
}

function isAutoUpdateEnabled {
    $cfgKeys = getConfigNames

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

function setAutoUpdateEnabled([bool]$enable) {
    $cfgKeys = getConfigNames

    set-itemproperty -path $cfgKeys.regPath -name $cfgKeys.regAutoUpdate -value $enable -Force
}

Export-ModuleMember -Function getStoredLocation, setStoredLocation, isAutoUpdateEnabled, setAutoUpdateEnabled