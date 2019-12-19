Import-Module .\lib\location\coordinates.psm1
Import-Module .\lib\time\time.psm1
Import-Module .\lib\settings\location.psm1

function getSunEventsForHereAndNow {
    Write-Host "Retrieving sun events for here and now"
    $coords = getStoredLocation
    $ts = getTimestamp
    $autoUpdate = isAutoUpdateEnabled

    if ((($null -eq $coords.latitude) -or ($null -eq $coords.longitude)) -and $false -eq $autoUpdate) {
        Write-Error "No location defined and auto-update disabled, can't continue."
    } else {
        if (($null -eq $coords.timestamp) -or ([long]$coords.timestamp + 86400 -lt [long]$ts) -or $null -eq $coords.latitude -or $null -eq $coords.longitude) {
            Write-Host "No or outdated coords, calculating new."
            $c = getCoordinates
            $coords.latitude = $c.latitude
            $coords.longitude = $c.longitude
            setStoredLocation -latitude $coords.latitude -longitude $coords.longitude
        } else {
            Write-Host "Using cached location."
        }
    
        Write-Host "coords = ${coords}"
        $date = (get-Date -Format "yyyy,M,d").Split(",")
        $offset = getTimezoneOffset
        $events = (getSunEvents -year $date[0] -month $date[1] -day $date[2] -latitude $coords.Latitude -longitude $coords.Longitude)
        $events.sunrise += $offset
        $events.sunset += $offset
        $events.transition += $offset
    }
    return $events 
}

function getLighting {
    Write-Host "Calculating current lighting progress"
    $hour = getHourAsDecimal
    $events = getSunEventsForHereAndNow
    $sunrise = ($events.sunrise - 1)        # we expand day by 1h since sun is already glowing
    $sunset = ($events.sunset + 1.5)        # we expand day by 1.5h since sun is still glowing
    $daylength = $sunset - $sunrise

    $value = "" | Select-Object -Property section,progress,brightness,image

    $value.section = "day"
    $value.progress = 0.5
    $value.brightness = 55

    # sunrise, day, sunset
    if ($hour -ge $sunrise -and $hour -le $sunset) {
        $morningMax = $sunrise + ($daylength / 3)
        $dayMax = $sunset - ($daylength / 3)

        if ($hour -lt $morningMax) {
            $value.section = "sunrise"
            $length = $morningMax - $sunrise
            $value.progress = ($hour - $sunrise)/$length
            $value.brightness = 30
        }

        if ($hour -gt $dayMax) {
            $value.section = "sunset"
            $length = $sunset - $dayMax
            $value.progress = ($hour - $dayMax)/$length
            $value.brightness = 35
        }
    } else { # night
        $value.section = "night"
        $length = ($sunrise - $sunset + 24)
        if ($hour -lt $sunset) {
            $value.progress = ($hour - $sunset + 24)/$length
        } else {
            $value.progress = ($hour - $sunset)/$length
        }
        $value.brightness = 10
    }

    Write-Host "hour = ${hour}"
    Write-Host "value = ${value}"
    Write-Host "adjusted sunrise = ${sunrise}, adjusted sunset = ${sunset}"

    return $value
}

function loadTheme([string]$themePath) {
    Write-Host "Loading '${themePath}' theme file"
    try {
        return [IO.File]::ReadAllText($themePath) | ConvertFrom-Json
    } catch {
        return $null
    }
}

function getNameAndImage($theme) {
    $state = getLighting
    $state.image = [Math]::Ceiling($theme.$($state.section).Length * $state.progress) 
    return $state
}

function setSystemAndAppTheme([string]$section) {
    switch($section) {
        "day" {
            setLightAppTheme
            setLightSystemTheme
        }
        "night" {
            setDarkAppTheme
            setDarkSystemTheme
        }
        "sunset" {
            setLightAppTheme
            setDarkSystemTheme
        }
        "sunrise" {
            setLightAppTheme
            setDarkSystemTheme
        }
    }
}

Export-ModuleMember -Function *