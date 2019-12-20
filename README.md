# Wallpaperer
Time and location-based Windows 10 wallpaper, lockscreen and system theme changer. Written to get a grip on PowerShell.

**Disclaimer**

> This code was written just for fun and is provided AS-IS, if it breaks your machine, cat, dishwasher, mood or anything, **you** take full responsibility.

**Requirements**

> You should enable local script execution by calling `set-executionpolicy remotesigned` in admin PowerShell console.

All images are (c) by Apple Inc.

## How does it work
- it uses Windows location API to determine your geolocation
- it calculates sunrise and susnet times for your geolocation
- it applies wallpaper, lockscreen and system theme basing on the provided theme file (the format is self-explanatory)
- you can override most of the settings using either the provided `settings.ps1` file (run it using `settings.vba`) or via `regedit`: `HKCU:\Software\WrobelConsulting\Wallpaperer`
 - `Latitude` and `Longitude` define your location (you can specify your location here if you wish to have it private)
 - `Timestamp` defines last location acuire timestamp (re-acquire after `Timestamp` + 24h; you can add like a trailing `0` here if you don't want your location to be re-determined)
 - `Theme` defines current theme path to use


## How to use
Set execution of `run.vba` script using Windows Task Scheduler to run on user login and every hour (or more often, if you prefer); just make sure to set _Start in..._ property to the path where `wallpaperer.ps1` is located.
