function getHourAsDecimal {
    $hour = (get-Date -Format "HH,mm").Split(",")
    return ([int]$hour[0]) + ([int]($hour[1])/60)
}

function getTimezoneOffset {
    $off = Get-Date -UFormat "%Z"
    [convert]::ToInt32($off)
}

function getTimestamp {
    return [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
}

Export-ModuleMember getHourAsDecimal, getTimezoneOffset, getTimestamp