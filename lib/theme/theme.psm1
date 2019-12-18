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

Export-ModuleMember -Function set-LightAppTheme, set-DarkAppTheme, set-LightSystemTheme, set-DarkSystemTheme, set-Theme, set-SystemTheme, set-AppTheme