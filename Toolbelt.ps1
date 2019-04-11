Import-Module "$PSScriptRoot\Modules\Remove Bloatware.psm1" -Force
Import-Module "$PSScriptRoot\Modules\Tweaks.psm1"

Write-Host "Building GUI..." -ForegroundColor Yellow

Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Aspire IT Toolbelt"
$main_form.Width = 1200
$main_form.Height = 400
$main_form.AutoSize = $true

$Credit = New-Object System.Windows.Forms.Label
$Credit.Text = "Aspire IT Toolbelt"
$Credit.Location = New-Object System.Drawing.Point(550, 40)
$Credit.AutoSize = $true
$main_form.Controls.Add($Credit)

$LogoPath = "$PSScriptRoot\Assets\Images\Logo.png"
$LogoImg = [System.Drawing.Image]::Fromfile($LogoPath)
$Logo = new-object Windows.Forms.PictureBox
$Logo.Width = $LogoImg.Size.Width
$Logo.Height = $LogoImg.Size.Height
$Logo.Image = $LogoImg
$main_form.controls.add($Logo)

$Console = New-Object System.Windows.Forms.TextBox
$Console.Text = ""
$Console.Location = New-Object System.Drawing.Size(620,100)
$Console.Size = New-Object System.Drawing.Size(540,280)
$Console.Multiline = $true
$main_form.Controls.Add($Console)

$RemoveBloatware = New-Object System.Windows.Forms.Button
$RemoveBloatware.Text = "Remove Bloatware"
$RemoveBloatware.Location = New-Object System.Drawing.Size(20, 100)
$RemoveBloatware.Size = New-Object System.Drawing.Size(200, 50)
$RemoveBloatware.Add_Click( {
    Remove-Bloatware $Console
})
$main_form.Controls.Add($RemoveBloatware)

$Tweaks = New-Object System.Windows.Forms.Button
$Tweaks.Text = "Tweaks"
$Tweaks.Location = New-Object System.Drawing.Size(240, 100)
$Tweaks.Size = New-Object System.Drawing.Size(200, 50)
$Tweaks.Add_Click( {
    Tweaks $Console
})
$main_form.Controls.Add($Tweaks)

$main_form.ShowDialog()