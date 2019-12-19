$base = $PSScriptRoot
# $base = Get-Location
Import-Module -Name .\lib\system\culture.psm1
Import-Module -Name .\lib\sun\sunevents.psm1
Import-Module -Name .\lib\wallpaper\wallpaper.psm1
Import-Module -Name .\lib\wallpaper\lockscreen.psm1
Import-Module -Name .\lib\theme\theme.psm1
Import-Module -Name .\lib\time\time.psm1
Import-Module -Name .\lib\location\coordinates.psm1
Import-Module -Name .\lib\settings\location.psm1
Import-Module -Name .\lib\settings\themepath.psm1
Import-Module -Name .\lib\settings\regpaths.psm1
Import-Module -Name .\lib\system\brightness.psm1

function get-SunEventsForHereAndNow {
    Write-Host "Retrieving sun events for here and now"
    $coords = get-StoredLocation
    $ts = get-Timestamp
    $autoUpdate = isAutoUpdate
    if (($null -eq $coords.timestamp) -or ([long]$coords.timestamp + 86400 -lt [long]$ts) -or $null -eq $coords.latitude -or $null -eq $coords.longitude) {
        Write-Host "No or outdated coords, calculating new."
        $c = get-Coordinates
        $coords.latitude = $c.latitude
        $coords.longitude = $c.longitude
        set-StoredLocation -latitude $coords.latitude -longitude $coords.longitude
    } else {
        Write-Host "Using cached location."
    }

    Write-Host "coords = ${coords}"
    $date = (get-Date -Format "yyyy,M,d").Split(",")
    $offset = get-TzOffset
    $events = (get-SunEvents -year $date[0] -month $date[1] -day $date[2] -latitude $coords.Latitude -longitude $coords.Longitude)
    $events.sunrise += $offset
    $events.sunset += $offset
    $events.transition += $offset
    return $events 
}

function get-Lighting {
    Write-Host "Calculating current lighting progress"
    $hour = get-Hour
    $events = get-SunEventsForHereAndNow
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

function get-Theme([string]$themePath) {
    Write-Host "Loading '${themePath}' theme file"
    try {
        return [IO.File]::ReadAllText($themePath) | ConvertFrom-Json
    } catch {
        return $null
    }
}

function get-NameAndImage($theme) {
    $state = get-Lighting
    $state.image = [Math]::Ceiling($theme.$($state.section).Length * $state.progress) 
    return $state
}

function set-SystemAndAppTheme([string]$section) {
    switch($section) {
        "day" {
            set-LightAppTheme
            set-LightSystemTheme
        }
        "night" {
            set-DarkAppTheme
            set-DarkSystemTheme
        }
        "sunset" {
            set-LightAppTheme
            set-DarkSystemTheme
        }
        "sunrise" {
            set-LightAppTheme
            set-DarkSystemTheme
        }
    }
}

resetCulture
$themePath = get-SavedThemePath
$theme = get-Theme -themePath $themePath
if ($null -ne $theme) {
    $settings = get-NameAndImage -theme $theme
    $folder = $theme.folder
    $imgOffset = $theme.($settings.section)
    $imagesPath = [System.IO.Path]::GetDirectoryName($themePath)
    $imgPath = "${imagesPath}\${folder}\$($imgOffset[$settings.image - 1])"
    if (Test-Path -Path $imgPath) {
        set-Wallpaper -desktopImage $imgPath
        set-LockscreenWallpaper -imagePath $imgPath
    } else {
        Write-Error "Image '${imgPath}' not found."
    }
    set-SystemAndAppTheme -section $settings.section
    set-Brightness -brightness $settings.brightness
} else {
    Write-Error "Failed to load theme '${themePath}', aborting."
}