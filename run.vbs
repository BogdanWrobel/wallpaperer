Dim objShell, objFSO, objFile

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strPath = "wallpaperer.ps1"

If objFSO.FileExists(strPath) Then
    set objFile = objFSO.GetFile(strPath)
    strCMD = "powershell -nologo -command " & Chr(34) & "&{" & objFile.ShortPath & "}" & Chr(34) 
    objShell.Run strCMD,0

Else
    WScript.Echo strPath & " not found, aborting."
    WScript.Quit    
End If