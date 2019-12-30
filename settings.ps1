# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

Import-Module -Name .\lib\system\culture.psm1
Import-Module -Name .\lib\sun\sunevents.psm1
Import-Module -Name .\lib\system\wallpaper.psm1
Import-Module -Name .\lib\system\lockscreen.psm1
Import-Module -Name .\lib\system\theme.psm1
Import-Module -Name .\lib\time\time.psm1
Import-Module -Name .\lib\location\coordinates.psm1
Import-Module -Name .\lib\regconfig\location.psm1
Import-Module -Name .\lib\theme\theme.psm1
Import-Module -Name .\lib\regconfig\regpaths.psm1
Import-Module -Name .\lib\system\brightness.psm1
Import-Module -Name .\lib\wallpaperer\functions.psm1



function get-SettingsForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)


    $settingsForm                    = New-Object system.Windows.Forms.Form
    $settingsForm.ClientSize         = '290,231'
    $settingsForm.text               = "Wallpaperer"
    $settingsForm.TopMost            = $true
    $settingsForm.TopMost            = $true
    $settingsForm.FormBorderStyle    = 1 # FormBorderStyle.FixedSingle
    $settingsForm.MaximizeBox        = $false
    $settingsForm.MinimizeBox        = $false
    

    $lonLabel                        = New-Object system.Windows.Forms.Label
    $lonLabel.text                   = "Longitude"
    $lonLabel.AutoSize               = $true
    $lonLabel.width                  = 25
    $lonLabel.height                 = 10
    $lonLabel.location               = New-Object System.Drawing.Point(17,46)
    $lonLabel.Font                   = $Font
    $lonLabel.Name                   = "lonLabel"

    $latLabel                        = New-Object system.Windows.Forms.Label
    $latLabel.text                   = "Latitude"
    $latLabel.AutoSize               = $true
    $latLabel.width                  = 25
    $latLabel.height                 = 10
    $latLabel.location               = New-Object System.Drawing.Point(17,21)
    $latLabel.Font                   = $Font

    $lonTextBox                      = New-Object system.Windows.Forms.TextBox
    $lonTextBox.multiline            = $false
    $lonTextBox.width                = 114
    $lonTextBox.height               = 20
    $lonTextBox.location             = New-Object System.Drawing.Point(81,43)
    $lonTextBox.Font                 = $Font

    $latTextBox                      = New-Object system.Windows.Forms.TextBox
    $latTextBox.multiline            = $false
    $latTextBox.width                = 114
    $latTextBox.height               = 20
    $latTextBox.location             = New-Object System.Drawing.Point(81,20)
    $latTextBox.Font                 = $Font

    $detectlocationButton            = New-Object system.Windows.Forms.Button
    $detectlocationButton.text       = "Detect"
    $detectlocationButton.width      = 60
    $detectlocationButton.height     = 45
    $detectlocationButton.location   = New-Object System.Drawing.Point(204,19)
    $detectlocationButton.Font       = $Font

    $autoLocationCheckBox            = New-Object system.Windows.Forms.CheckBox
    $autoLocationCheckBox.text       = "Refresh automatically"
    $autoLocationCheckBox.AutoSize   = $false
    $autoLocationCheckBox.width      = 202
    $autoLocationCheckBox.height     = 20
    $autoLocationCheckBox.location   = New-Object System.Drawing.Point(17,72)
    $autoLocationCheckBox.Font       = $Font

    $locationGroupbox                = New-Object system.Windows.Forms.Groupbox
    $locationGroupbox.height         = 95
    $locationGroupbox.width          = 274
    $locationGroupbox.text           = "Coordinates"
    $locationGroupbox.location       = New-Object System.Drawing.Point(8,13)
    $locationGroupbox.Font           = $Font

    $themeGroupBox                   = New-Object system.Windows.Forms.Groupbox
    $themeGroupBox.height            = 64
    $themeGroupBox.width             = 274
    $themeGroupBox.text              = "Theme"
    $themeGroupBox.location          = New-Object System.Drawing.Point(8,118)
    $themeGroupBox.Font              = $Font

    $themeTextBox                    = New-Object system.Windows.Forms.TextBox
    $themeTextBox.multiline          = $false
    $themeTextBox.width              = 189
    $themeTextBox.height             = 20
    $themeTextBox.location           = New-Object System.Drawing.Point(10,14)
    $themeTextBox.Font               = $Font
    $themeTextBox.ReadOnly           = $true

    $changeThemeButton               = New-Object system.Windows.Forms.Button
    $changeThemeButton.text          = "..."
    $changeThemeButton.width         = 60
    $changeThemeButton.height        = 25
    $changeThemeButton.location      = New-Object System.Drawing.Point(208,13)
    $changeThemeButton.Font          = $Font

    $whiteTaskbarCheckBox            = New-Object system.Windows.Forms.CheckBox
    $whiteTaskbarCheckBox.text       = "Use light taskbar for day theme"
    $whiteTaskbarCheckBox.AutoSize   = $false
    $whiteTaskbarCheckBox.width      = 202
    $whiteTaskbarCheckBox.height     = 20
    $whiteTaskbarCheckBox.location   = New-Object System.Drawing.Point(17,40)
    $whiteTaskbarCheckBox.Font       = $Font

    $okButton                        = New-Object system.Windows.Forms.Button
    $okButton.text                   = "Save"
    $okButton.width                  = 90
    $okButton.height                 = 30
    $okButton.location               = New-Object System.Drawing.Point(99,193)
    $okButton.Font                   = $Font

    
    # $trackBar                        = New-Object System.Windows.Forms.TrackBar
    # $trackBar.width                  = 400
    # $trackBar.height                 = 30
    # $trackBar.location               = New-Object System.Drawing.Point(0,183)
    # $trackBar.Font                   = $Font

    

    $locationGroupbox.controls.AddRange(@($lonLabel,$latLabel,$lonTextBox,$latTextBox,$detectlocationButton,$autoLocationCheckBox))
    $themeGroupBox.controls.AddRange(@($themeTextBox,$changeThemeButton,$whiteTaskbarCheckBox))
    $settingsForm.controls.AddRange(@($locationGroupbox,$themeGroupBox,$okButton))

    $detectLocationClickHandler = { 
        $detectlocationButton.Enabled = $false
        $latTextBox.Enabled = $false
        $lonTextBox.Enabled = $false

        $coords = getCoordinates
        $latTextBox.Lines = $coords.Latitude
        $lonTextBox.Lines = $coords.Longitude

        $latTextBox.Enabled = $true
        $lonTextBox.Enabled = $true
        $detectlocationButton.Enabled = $true
    }.GetNewClosure()

    $saveSettingsClickHandler = {
        setStoredLocation -latitude $latTextBox.Text -longitude $lonTextBox.Text
        setAutoUpdateEnabled -enable $autoLocationCheckBox.Checked
        setWhiteTaskbarEnabled -enable $whiteTaskbarCheckBox.Checked
        setSavedThemePath -themePath $themeTextBox.Text
        $okButton.Text = "Applying..."
        $settingsForm.Enabled = $false
        . .\wallpaperer.ps1
        $settingsForm.Close()
    }.GetNewClosure()

    $changeThemeClickHandler = {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [System.IO.Path]::GetDirectoryName($themeTextBox.Text)
            Filter = 'Themes (*.json)|*.json' 
        }
        $FileBrowser.ShowDialog()
        if ("" -ne $FileBrowser.FileName) {
            $themeValid = isThemeValid -themePath $FileBrowser.FileName
            if ($themeValid) {
                $themeTextBox.Lines = $FileBrowser.FileName
            } else {
                $null = (New-Object -ComObject Wscript.Shell).Popup('Theme file looks invalid, please try again.', 0, 'Error', 16)
            }
        }
    }.GetNewClosure()

    $detectlocationButton.Add_Click($detectLocationClickHandler)
    $okButton.Add_Click($saveSettingsClickHandler)
    $changeThemeButton.Add_Click($changeThemeClickHandler)

    # loading current settings
    $savedCoords = getStoredLocation
    $latTextBox.Lines = $savedCoords.Latitude
    $lonTextBox.Lines = $savedCoords.Longitude
    $themeTextBox.Lines = getSavedThemePath -basePath $PSScriptRoot
    $autoLocationCheckBox.Checked = isAutoUpdateEnabled
    $whiteTaskbarCheckBox.Checked = isWhiteTaskbarEnabled

    return $settingsForm
}

resetCulture

$form = get-SettingsForm
$null = $form.ShowDialog()