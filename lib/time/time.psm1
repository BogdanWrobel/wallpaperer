function get-Hour {
    $hour = (get-Date -Format "HH,mm").Split(",")
    return ([int]$hour[0]) + ([int]($hour[1])/60)
}

function get-TzOffset {
    $off = Get-Date -UFormat "%Z"
    [convert]::ToInt32($off)
}

function get-Timestamp {
    return [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
}

Export-ModuleMember get-Hour, get-TzOffset, get-Timestamp