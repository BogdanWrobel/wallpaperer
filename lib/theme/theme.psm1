function setTheme([string]$property, [int]$isLight) {
    Write-Host "Setting '${property}' to '${isLight}'"
    set-itemproperty -path "HKCU:Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name $property -value $isLight
}

function setSystemTheme([int]$isLight) {
    setTheme -property "SystemUsesLightTheme" -isLight $isLight
}

function setAppTheme([int]$isLight) {
    setTheme -property "AppsUseLightTheme" -isLight $isLight
}

function setLightAppTheme {
    setAppTheme -isLight 1
}

function setDarkAppTheme {
    setAppTheme -isLight 0
}

function setLightSystemTheme {
    setSystemTheme -isLight 1
}

function setDarkSystemTheme {
    setSystemTheme -isLight 0
}

Export-ModuleMember -Function setLightAppTheme, setDarkAppTheme, setLightSystemTheme, setDarkSystemTheme, setTheme, setSystemTheme, setAppTheme