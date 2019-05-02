if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Import modules
Import-Module "$PSScriptRoot\Modules\Remove Bloatware.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Tweaks.psm1"
Import-Module "$PSScriptRoot\Modules\Distribute Software.psm1" -WarningAction SilentlyContinue

# Import settings
$Settings = Get-Content "$PSScriptRoot\Settings.json" | ConvertFrom-Json

Write-Host "Building GUI..." -ForegroundColor Yellow

Add-Type -assembly System.Windows.Forms

$ButtonFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Regular)
$ConsoleFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)

$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$machineType = $osInfo.ProductType
switch ($machineType) {
    1 {Write-Host "Workstation" -ForegroundColor Green}
    2 {Write-Host "Domain Controller" -ForegroundColor Green}
    3 {Write-Host "Server" -ForegroundColor Green}
}

# ---------------------------------------- INITIALIZE FORM ----------------------------------------

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Aspire IT Toolbelt"
$main_form.Width = 1200
$main_form.Height = 780
$main_form.AutoSize = $true

# ---------------------------------------- BEGIN LOGO ----------------------------------------

$LogoPath = "$PSScriptRoot\Assets\Images\Logo.png"
$LogoImg = [System.Drawing.Image]::Fromfile($LogoPath)
$Logo = new-object Windows.Forms.PictureBox
$Logo.Width = $LogoImg.Size.Width
$Logo.Height = $LogoImg.Size.Height
$Logo.Image = $LogoImg
$Logo.Location = New-Object System.Drawing.Size([int]($main_form.Width / 2 - $Logo.Width / 2), 10)
$main_form.controls.add($Logo)

# ---------------------------------------- BEGIN CONSOLE ----------------------------------------

$ConsoleGroup = New-Object System.Windows.Forms.GroupBox
$ConsoleGroup.Location = New-Object System.Drawing.Size(610, 100)
$ConsoleGroup.Size = New-Object System.Drawing.Size(550, 620)
$ConsoleGroup.Text = "Console"
$main_form.Controls.Add($ConsoleGroup)

$Console = New-Object System.Windows.Forms.RichTextBox
$Console.Text = ""
$Console.Location = New-Object System.Drawing.Size(10,20)
$Console.Size = New-Object System.Drawing.Size(520,580)
$Console.Multiline = $true
$Console.ReadOnly = $true
$Console.BackColor = [System.Drawing.Color]::Black
$Console.ForeColor = [System.Drawing.Color]::LimeGreen
$Console.Font = $ConsoleFont
$ConsoleGroup.Controls.Add($Console)

# ---------------------------------------- BEGIN WORKSTATION CONTROLS ----------------------------------------

$WorkstationGroup = New-Object System.Windows.Forms.GroupBox
$WorkstationGroup.Location = New-Object System.Drawing.Size(20, 100)
$WorkstationGroup.Size = New-Object System.Drawing.Size(570, 300)
$WorkstationGroup.Text = "Workstation Controls"
$main_form.Controls.Add($WorkstationGroup)

$RemoveBloatware = New-Object System.Windows.Forms.Button
$RemoveBloatware.Text = "Remove Bloatware"
$RemoveBloatware.Location = New-Object System.Drawing.Size(20, 20)
$RemoveBloatware.Size = New-Object System.Drawing.Size(200, 50)
$RemoveBloatware.Font = $ButtonFont
$RemoveBloatware.Add_Click( {
    Remove-Bloatware $Console
})
$WorkstationGroup.Controls.Add($RemoveBloatware)

$Tweaks = New-Object System.Windows.Forms.Button
$Tweaks.Text = "Tweaks"
$Tweaks.Location = New-Object System.Drawing.Size(240, 20)
$Tweaks.Size = New-Object System.Drawing.Size(200, 50)
$Tweaks.Font = $ButtonFont
$Tweaks.Add_Click( {
    Tweaks $Console
})
$WorkstationGroup.Controls.Add($Tweaks)

# ---------------------------------------- BEGIN SERVER CONTROLS ----------------------------------------

$DCGroup = New-Object System.Windows.Forms.GroupBox
$DCGroup.Location = New-Object System.Drawing.Size(20, 420)
$DCGroup.Size = New-Object System.Drawing.Size(570, 300)
$DCGroup.Text = "Domain Controller Controls"
if ($machineType -eq 2 -or $Settings.debug) {
    $main_form.Controls.Add($DCGroup)
}

$DistrubuteSoftware = New-Object System.Windows.Forms.Button
$DistrubuteSoftware.Text = "Distribute Software"
$DistrubuteSoftware.Location = New-Object System.Drawing.Size(20, 20)
$DistrubuteSoftware.Size = New-Object System.Drawing.Size(200, 50)
$DistrubuteSoftware.Font = $ButtonFont
$DistrubuteSoftware.Add_Click( {
    Distribute-Software -Console $Console
})
$DCGroup.Controls.Add($DistrubuteSoftware)

$UpgradeAllToWin10 = New-Object System.Windows.Forms.Button
$UpgradeAllToWin10.Text = "Upgrade Network Computers to Windows 10"
$UpgradeAllToWin10.Location = New-Object System.Drawing.Size(20, 80)
$UpgradeAllToWin10.Size = New-Object System.Drawing.Size(200, 50)
$UpgradeAllToWin10.Font = $ButtonFont
$UpgradeAllToWin10.Add_Click( {
    $Console.Clear()
    $Console.AppendText("Coming soon...")
    #i5 +
    #8Gb ram +
    #2 years old -
    #64bit only
})
$DCGroup.Controls.Add($UpgradeAllToWin10)



# Display Form
Write-Host "GUI Built... Showing Dialog..." -ForegroundColor Yellow
$main_form.ShowDialog()