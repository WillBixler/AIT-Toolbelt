if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Import modules
Import-Module "$PSScriptRoot\Modules\Remove Bloatware.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Tweaks.psm1"
Import-Module "$PSScriptRoot\Modules\Distribute Software.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Install ScreenConnect.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Install Pulseway.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Install Chrome.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Install Acrobat Reader.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Update.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Workgroup Tweaks.psm1" -Force

# Import settings
if (Get-Item "$PSScriptRoot\Settings.json" -Force -ErrorAction SilentlyContinue) {
    Write-Host "Found Settings file... Loading..." -ForegroundColor Yellow

    $Settings = Get-Content "$PSScriptRoot\Settings.json" | ConvertFrom-Json -ErrorAction SilentlyContinue
} else {
    Write-Host "Settings file not found... Creating it..." -ForegroundColor Yellow

    $Settings = New-Object -TypeName psobject
    $Settings | Add-Member -MemberType NoteProperty -Name debug -Value $false

    $Settings | ConvertTo-Json | Out-File "$PSScriptRoot\Settings.json"
    (Get-Item "$PSScriptRoot\Settings.json" -Force).Attributes += "Hidden"
}

if (Get-Item "$PSScriptRoot\Info.json" -Force -ErrorAction SilentlyContinue) {
    Write-Host "Found Info file... Loading..." -ForegroundColor Yellow

    $Info = Get-Content "$PSScriptRoot\Info.json" | ConvertFrom-Json -ErrorAction SilentlyContinue
} else {
    Write-Host "Info file not found... Creating it..." -ForegroundColor Yellow

    $Info = New-Object -TypeName psobject
    $Info | Add-Member -MemberType NoteProperty -Name Name -Value "Aspire IT Toolbelt"
    $Info | Add-Member -MemberType NoteProperty -Name Version -Value "0.0.0"

    $Info | ConvertTo-Json | Out-File "$PSScriptRoot\Info.json"
}

$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$machineType = $osInfo.ProductType
switch ($machineType) {
    1 { Write-Host "Machine type: Workstation" -ForegroundColor Yellow }
    2 { Write-Host "Machine type: Domain Controller" -ForegroundColor Yellow }
    3 { Write-Host "Machine type: Server" -ForegroundColor Yellow }
}

Write-Host "Building GUI..." -ForegroundColor Yellow

Add-Type -assembly System.Windows.Forms

$ButtonFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Regular)
$ConsoleFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)

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

# ---------------------------------------- BEGIN Version ----------------------------------------

$Version = new-object Windows.Forms.Label
$Version.Width = 100
$Version.Height = 20
$Version.Text = "Version: " + $Info.Version
$Version.Location = New-Object System.Drawing.Size(10, 10)
$main_form.controls.add($Version)

$UpdateButton = New-Object System.Windows.Forms.Button
$UpdateButton.Text = "Update"
$UpdateButton.Location = New-Object System.Drawing.Size(10, 30)
$UpdateButton.Size = New-Object System.Drawing.Size(70, 20)
#$UpdateButton.Font = $ButtonFont
$UpdateButton.Add_Click( {
    if ((Update $Console $PSScriptRoot $Info.Version) -eq $true) {
        $main_form.Close();
    }
})
$main_form.Controls.Add($UpdateButton)

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
$RemoveBloatware.Size = New-Object System.Drawing.Size(255, 50)
$RemoveBloatware.Font = $ButtonFont
$RemoveBloatware.Add_Click( {
    Remove-Bloatware $Console
})
$WorkstationGroup.Controls.Add($RemoveBloatware)

$Tweaks = New-Object System.Windows.Forms.Button
$Tweaks.Text = "Tweaks"
$Tweaks.Location = New-Object System.Drawing.Size(295, 20)
$Tweaks.Size = New-Object System.Drawing.Size(255, 50)
$Tweaks.Font = $ButtonFont
$Tweaks.Add_Click( {
    Tweaks $Console
})
$WorkstationGroup.Controls.Add($Tweaks)

$InstallScreenConnect = New-Object System.Windows.Forms.Button
$InstallScreenConnect.Text = "Install ScreenConnect"
$InstallScreenConnect.Location = New-Object System.Drawing.Size(20, 80)
$InstallScreenConnect.Size = New-Object System.Drawing.Size(255, 50)
$InstallScreenConnect.Font = $ButtonFont
$InstallScreenConnect.Add_Click( {
    Install-ScreenConnect $Console
})
$WorkstationGroup.Controls.Add($InstallScreenConnect)

$InstallPulseway = New-Object System.Windows.Forms.Button
$InstallPulseway.Text = "Install Pulseway"
$InstallPulseway.Location = New-Object System.Drawing.Size(295, 80)
$InstallPulseway.Size = New-Object System.Drawing.Size(255, 50)
$InstallPulseway.Font = $ButtonFont
$InstallPulseway.Add_Click( {
    Install-Pulseway $Console
})
$WorkstationGroup.Controls.Add($InstallPulseway)

$InstallChrome = New-Object System.Windows.Forms.Button
$InstallChrome.Text = "Install Chrome"
$InstallChrome.Location = New-Object System.Drawing.Size(20, 140)
$InstallChrome.Size = New-Object System.Drawing.Size(255, 50)
$InstallChrome.Font = $ButtonFont
$InstallChrome.Add_Click( {
    Install-Chrome $Console
})
$WorkstationGroup.Controls.Add($InstallChrome)

$InstallReader = New-Object System.Windows.Forms.Button
$InstallReader.Text = "Install Adobe Acrobat Reader DC"
$InstallReader.Location = New-Object System.Drawing.Size(295, 140)
$InstallReader.Size = New-Object System.Drawing.Size(255, 50)
$InstallReader.Font = $ButtonFont
$InstallReader.Add_Click( {
    Install-AcrobatReader $Console
})
$WorkstationGroup.Controls.Add($InstallReader)

$WorkgroupTweaks = New-Object System.Windows.Forms.Button
$WorkgroupTweaks.Text = "WORKGROUP Tweaks"
$WorkgroupTweaks.Location = New-Object System.Drawing.Size(20, 200)
$WorkgroupTweaks.Size = New-Object System.Drawing.Size(255, 50)
$WorkgroupTweaks.Font = $ButtonFont
$WorkgroupTweaks.Add_Click( {
    WorkgroupTweaks $Console
})
$WorkstationGroup.Controls.Add($WorkgroupTweaks)

# ---------------------------------------- BEGIN NETWORK CONTROLS ----------------------------------------

$DCGroup = New-Object System.Windows.Forms.GroupBox
$DCGroup.Location = New-Object System.Drawing.Size(20, 420)
$DCGroup.Size = New-Object System.Drawing.Size(570, 300)
$DCGroup.Text = "Network Controls"

$main_form.Controls.Add($DCGroup)

$DistrubuteSoftware = New-Object System.Windows.Forms.Button
$DistrubuteSoftware.Text = "Distribute Software"
$DistrubuteSoftware.Location = New-Object System.Drawing.Size(20, 20)
$DistrubuteSoftware.Size = New-Object System.Drawing.Size(255, 50)
$DistrubuteSoftware.Font = $ButtonFont
$DistrubuteSoftware.Add_Click( {
    Push-Software -Console $Console
})
$DCGroup.Controls.Add($DistrubuteSoftware)

$UpgradeAllToWin10 = New-Object System.Windows.Forms.Button
$UpgradeAllToWin10.Text = "Upgrade Network Computers to Windows 10"
$UpgradeAllToWin10.Location = New-Object System.Drawing.Size(295, 20)
$UpgradeAllToWin10.Size = New-Object System.Drawing.Size(255, 50)
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