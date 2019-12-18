function resetCulture {
    $culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
    $culture.NumberFormat.NumberDecimalSeparator = "."
    $culture.NumberFormat.NumberGroupSeparator = " "
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
}

Export-ModuleMember -Function resetCulture