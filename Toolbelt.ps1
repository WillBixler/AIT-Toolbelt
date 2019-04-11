if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Import-Module "$PSScriptRoot\Modules\Remove Bloatware.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Tweaks.psm1"

Write-Host "Building GUI..." -ForegroundColor Yellow

Add-Type -assembly System.Windows.Forms

$LabelFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
$ButtonFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Regular)
$ConsoleFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)

# ---------------------------------------- INITIALIZE FORM ----------------------------------------

Add-Type -assembly System.Windows.Forms
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

$ServerGroup = New-Object System.Windows.Forms.GroupBox
$ServerGroup.Location = New-Object System.Drawing.Size(20, 420)
$ServerGroup.Size = New-Object System.Drawing.Size(570, 300)
$ServerGroup.Text = "Server Controls"
$main_form.Controls.Add($ServerGroup)

$DistributeCW = New-Object System.Windows.Forms.Button
$DistributeCW.Text = "Distribute ConnectWise"
$DistributeCW.Location = New-Object System.Drawing.Size(20, 20)
$DistributeCW.Size = New-Object System.Drawing.Size(200, 50)
$DistributeCW.Font = $ButtonFont
$DistributeCW.Add_Click( {
    $Console.Clear()
    $Console.AppendText("FEATURE COMING SOON...")
})
$ServerGroup.Controls.Add($DistributeCW)

$DistributePW = New-Object System.Windows.Forms.Button
$DistributePW.Text = "Distribute Pulseway"
$DistributePW.Location = New-Object System.Drawing.Size(240, 20)
$DistributePW.Size = New-Object System.Drawing.Size(200, 50)
$DistributePW.Font = $ButtonFont
$DistributePW.Add_Click( {
    $Console.Clear()
    $Console.AppendText("FEATURE COMING SOON...")
})
$ServerGroup.Controls.Add($DistributePW)

# Display Form
Write-Host "GUI Built... Showing Dialog..." -ForegroundColor Yellow
$main_form.ShowDialog()