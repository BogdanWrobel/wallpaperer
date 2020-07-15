$base = $PSScriptRoot
# $base = Get-Location
Import-Module -Name .\lib\system\culture.psm1
Import-Module -Name .\lib\sun\sunevents.psm1
Import-Module -Name .\lib\system\wallpaper.psm1
Import-Module -Name .\lib\system\lockscreen.psm1
Import-Module -Name .\lib\system\theme.psm1
Import-Module -Name .\lib\time\time.psm1
Import-Module -Name .\lib\location\coordinates.psm1
Import-Module -Name .\lib\regconfig\location.psm1
Import-Module -Name .\lib\theme\theme.psm1
Import-Module -Name .\lib\regconfig\regpaths.psm1
Import-Module -Name .\lib\system\brightness.psm1
Import-Module -Name .\lib\wallpaperer\functions.psm1

resetCulture
$themePath = getSavedThemePath -basePath $base
$theme = loadTheme -themePath $themePath
if ($null -ne $theme) {
    $settings = getNameAndImage -theme $theme
    $folder = $theme.folder
    $imgOffset = $theme.($settings.section)
    $imagesPath = [System.IO.Path]::GetDirectoryName($themePath)
    $imgPath = "${imagesPath}\${folder}\$($imgOffset[$settings.image - 1])"
    if (Test-Path -Path $imgPath) {
        setDesktopWallpaper -desktopImage $imgPath
        setLockscreenWallpaper -imagePath $imgPath
    } else {
        Write-Error "Image '${imgPath}' not found."
    }
    $whiteTaskbar = isWhiteTaskbarEnabled
    $keepTheme = isKeepTheme
    setSystemAndAppTheme -section $settings.section -whiteTaskbar $whiteTaskbar -keepTheme $keepTheme
    if (isAutoBrightnessEnabled) {
        setScreenBrightness -brightness $settings.brightness
    }
} else {
    Write-Error "Failed to load theme '${themePath}', aborting."
}