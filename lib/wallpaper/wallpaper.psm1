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

Export-ModuleMember -Function set-Wallpaper