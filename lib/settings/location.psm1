Import-Module .\lib\settings\regpaths.psm1 -Verbose

function set-StoredLocation([double]$latitude, [double]$longitude) {
    Write-Host "Saving location for further use"
    if (!(Test-Path -Path "${baseReg}\${companyReg}")) {
        New-Item -Path "${baseReg}\${companyReg}"
    }
    if (!(Test-Path -Path "${regPath}")) {
        New-Item -Path "${regPath}"
    } 

    $ts = get-Timestamp

    set-itemproperty -path $regPath -name $regLat -value $latitude -Force
    set-itemproperty -path $regPath -name $regLon -value $longitude -Force
    set-itemproperty -path $regPath -name $regStamp -value $ts -Force
}

function get-StoredLocation {
    Write-Host "Attempting to retrieve saved location."
    $value = "" | Select-Object -Property latitude,longitude,timestamp
    if (Test-Path -Path $regPath) {
        $properties = Get-ItemProperty -Path $regPath 
        if ($properties -and
            $null -ne (Get-Member -InputObject $properties -Name $regLat) -and
            $null -ne (Get-Member -InputObject $properties -Name $regLon) -and
            $null -ne (Get-Member -InputObject $properties -Name $regStamp)) {
           
            $lat = Get-ItemPropertyValue -Path $regPath -Name $regLat
            $lon = Get-ItemPropertyValue -Path $regPath -Name $regLon
            $value.latitude = ([double]::Parse($lat))
            $value.longitude = ([double]::Parse($lon))
            $value.timestamp = Get-ItemPropertyValue -Path $regPath -Name $regStamp
        }
    }
    return $value
}

Export-ModuleMember -Function get-StoredLocation, set-StoredLocation