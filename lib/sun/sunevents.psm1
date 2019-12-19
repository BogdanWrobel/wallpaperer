function getSunEvents([int]$year, [int]$month, [int]$day, [double]$latitude, [double]$longitude) {
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

Export-ModuleMember -Function getSunEvents