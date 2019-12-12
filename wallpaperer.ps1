# $base = $PSScriptRoot
$base = Get-Location

$culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
$culture.NumberFormat.NumberDecimalSeparator = "."
$culture.NumberFormat.NumberGroupSeparator = " "
[System.Threading.Thread]::CurrentThread.CurrentCulture = $culture

$baseReg = "HKCU:Software"
$companyReg = "WrobelConsulting"
$appReg = "Wallpaperer"
$regPath = "${baseReg}\${companyReg}\${appReg}"

$regLat = "Latitude"
$regLon = "Longitude"
$regStamp = "Timestamp"
$regTheme = "Theme"

function set-Wallpaper([string]$desktopImage) {
    Write-Host "Wallpaper to set: ${desktopImage}"
    Add-Type -TypeDefinition @" 
        using System; 
        using System.Runtime.InteropServices;
         
        public class Params
        { 
            [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
            public static extern int SystemParametersInfo (Int32 uAction, 
                                                           Int32 uParam, 
                                                           String lpvParam, 
                                                           Int32 fuWinIni);
        }
"@ 
         
        $SPI_SETDESKWALLPAPER = 0x0014
        $UpdateIniFile = 0x01
        $SendChangeEvent = 0x02
         
        $fWinIni = $UpdateIniFile -bor $SendChangeEvent
         
        [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $desktopImage, $fWinIni) | Out-Null
        
}

function set-Brightness([int]$brightness) {
    Write-Host "Setting brightness to ${brightness}"
    try {
        $ErrorActionPreference = "SilentlyContinue"
        $display = Get-WmiObject -Namespace "root\wmi" -Class "WmiMonitorBrightnessMethods"
        $display.WmiSetBrightness(2, $brightness)
    } catch {
        Write-Host "Brightness setting not supported on this machine."
    } finally {
        $ErrorActionPreference = "Continue"
    }
}

function set-Theme([string]$property, [int]$isLight) {
    Write-Host "Setting '${property}' to '${isLight}'"
    set-itemproperty -path "HKCU:Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name $property -value $isLight
}

function set-SystemTheme([int]$isLight) {
    set-Theme -property "SystemUsesLightTheme" -isLight $isLight
}

function set-AppTheme([int]$isLight) {
    set-Theme -property "AppsUseLightTheme" -isLight $isLight
}

function set-LightAppTheme {
    set-AppTheme -isLight 1
}

function set-DarkAppTheme {
    set-AppTheme -isLight 0
}

function set-LightSystemTheme {
    set-SystemTheme -isLight 1
}

function set-DarkSystemTheme {
    set-SystemTheme -isLight 0
}

function get-Hour {
    $hour = (get-Date -Format "HH,mm").Split(",")
    return ([int]$hour[0]) + ([int]($hour[1])/60)
}

function get-TzOffset {
    $off = Get-Date -UFormat "%Z"
    [convert]::ToInt32($off)
}

function get-Coordinates {
    Write-Host "Starting location resolver"
    Add-Type -AssemblyName System.Device 
    $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
    $GeoWatcher.Start()

    while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
        Write-Host "Waiting for location..."
        Start-Sleep -Milliseconds 500
    }  
    $value = "" | Select-Object -Property latitude,longitude

    if ($GeoWatcher.Permission -eq 'Denied'){
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

function get-SunEvents([int]$year, [int]$month, [int]$day, [double]$latitude, [double]$longitude) {
    Write-Host "Calculating sun events for ${year}-${month}-${day} @ ${latitude} : ${longitude}"
    $R = $year
    $M = $month
    $D = $day
    $Lon = $longitude
    $Lat = $latitude
    
    $Req = -0.833
    
    $J = 367 * $R - [Math]::Floor(7 * ($R + [Math]::Floor(($M + 9) / 12)) / 4) + [Math]::Floor(275 * $M / 9) + $D - 730531.5
    $Cent = $J/36525
    $L = (4.8949504201433 + 628.331969753199 * $Cent) % 6.28318530718
    $G = (6.2400408 + 628.3019501 * $Cent) % 6.28318530718
    $O = 0.409093 - 0.0002269 * $Cent
    $F = 0.033423 * [Math]::Sin($G) + 0.00034907 * [Math]::Sin(2 * $G)
    $E = 0.0430398 * [Math]::Sin(2 * ($L + $F)) - 0.00092502 * [Math]::Sin(4 * ($L + $F)) - $F
    $A = [Math]::ASin([Math]::Sin($O) * [Math]::Sin($L + $F))
    $C = ([Math]::Sin(0.017453293 * $Req) - [Math]::Sin(0.017453293 * $Lat) * [Math]::Sin($A)) / ([Math]::cos(0.017453293 * $Lat) * [Math]::cos($A))
    
    $value = "" | Select-Object -Property sunrise,sunset,transition
    $value.sunrise = ([Math]::PI - ($E + 0.017453293 * $Lon + 1 * [Math]::ACos($C))) * 57.29577951/15
    $value.transition = ([Math]::PI - ($E + 0.017453293 * $Lon + 0 * [Math]::ACos($C))) * 57.29577951/15
    $value.sunset = ([Math]::PI - ($E + 0.017453293 * $Lon + (-1) * [Math]::ACos($C))) * 57.29577951/15
    return $value
}

function get-SunEventsForHereAndNow {
    Write-Host "Retrieving sun events for here and now"
    $coords = get-StoredLocation
    $ts = get-Timestamp
    if (($null -eq $coords.timestamp) -or ([long]$coords.timestamp + 86400000 -lt [long]$ts) -or $null -eq $coords.latitude -or $null -eq $coords.longitude) {
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

function get-Timestamp {
    return [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
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

function set-LockscreenWallpaper([string]$imagePath) {
    $ProgressPreference = "SilentlyContinue"
    Write-Host "Lockscreen wallpaper to set: ${imagePath}"
    $newImagePath = "${env:TEMP}\" + (New-Guid).Guid + [System.IO.Path]::GetExtension($imagePath)

    Copy-Item $imagePath $newImagePath
    [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }
    function AwaitAction($WinRtAction) {
        $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
        $netTask = $asTask.Invoke($null, @($WinRtAction))
        $netTask.Wait(-1) | Out-Null
    }
    [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
    $image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($newImagePath)) ([Windows.Storage.StorageFile])
    AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))
    Remove-Item $newImagePath
    $ProgressPreference = "Continue"
}

function get-themePath {
    $theme = "${base}\themes\theme_catalina.json"
    if (Test-Path -Path $regPath) {
        $properties = Get-ItemProperty -Path $regPath 
        if ($properties -and
            $null -ne (Get-Member -InputObject $properties -Name $regTheme)) {
            $theme = Get-ItemPropertyValue -Path $regPath -Name $regTheme
        }
    }
    return ${theme}
}

$themePath = get-themePath
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
