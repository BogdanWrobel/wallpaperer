function setScreenBrightness([int]$brightness) {
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

Export-ModuleMember -Function setScreenBrightness