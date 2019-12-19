function getCoordinates {
    Write-Host "Starting location resolver"
    Add-Type -AssemblyName System.Device 
    $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
    $GeoWatcher.Start()

    while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
        Write-Host "Waiting for location..."
        Start-Sleep -Milliseconds 500
    }  
    $value = "" | Select-Object -Property latitude,longitude

    if ($GeoWatcher.Permission -eq 'Denied') {
        Write-Error 'Access Denied for Location Information'
        $value.latitude = 0
        $value.longitude = 0
    } else {
        Write-Host "Location found"
        $value.latitude = $GeoWatcher.Position.Location.Latitude
        $value.longitude = $GeoWatcher.Position.Location.Longitude
    }

    return $value
}

Export-ModuleMember -Function getCoordinates