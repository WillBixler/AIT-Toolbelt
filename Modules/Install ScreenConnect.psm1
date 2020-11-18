Function Install-ScreenConnect {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Installing ScreenConnect...")
    $Console.AppendText("`r`nChecking for previous installations...")

    $sc64 = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "ScreenConnect Client (c19beaeb65b0b26a)" }
    $sc32 = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "ScreenConnect Client (c19beaeb65b0b26a)" }

    if ($null -ne $sc64 -or $null -ne $sc32) {
        $Console.AppendText("`r`nScreenConnect already installed")
        return
    }
    
    $Console.AppendText("`r`n`tNo installation found")
    $PrimaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Regular)
    $SecondaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Regular)

    $popup = New-Object System.Windows.Forms.Form
    $popup.Text = "ScreenConnect Installer"
    $popup.AutoSize = $true

    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "ScreenConnect Installer"
    $titleLabel.TextAlign = "MiddleCenter"
    $titleLabel.Location = New-Object System.Drawing.Size(0, 0)
    $titleLabel.Size = New-Object System.Drawing.Size(350,50)
    $titleLabel.Font = $PrimaryFont
    $popup.Controls.Add($titleLabel)

    $companyLabel = New-Object System.Windows.Forms.Label
    $companyLabel.Text = "Company *"
    $companyLabel.Location = New-Object System.Drawing.Size(20, 60)
    $companyLabel.Size = New-Object System.Drawing.Size(80,20)
    $companyLabel.Font = $SecondaryFont
    $popup.Controls.Add($companyLabel)

    $companyInput = New-Object System.Windows.Forms.TextBox
    $companyInput.Location = New-Object System.Drawing.Size(120,60)
    $companyInput.Size = New-Object System.Drawing.Size(215,20)
    $companyInput.Text = ""
    $companyInput.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            if ((SubmitForm) -eq $true) {
                $popup.Close()
            }
        }
    })
    $popup.Controls.Add($companyInput)

    $siteLabel = New-Object System.Windows.Forms.Label
    $siteLabel.Text = "Site"
    $siteLabel.Location = New-Object System.Drawing.Size(20, 85)
    $siteLabel.Size = New-Object System.Drawing.Size(80,20)
    $siteLabel.Font = $SecondaryFont
    $popup.Controls.Add($siteLabel)

    $siteInput = New-Object System.Windows.Forms.TextBox
    $siteInput.Location = New-Object System.Drawing.Size(120,85)
    $siteInput.Size = New-Object System.Drawing.Size(215,20)
    $siteInput.Text = ""
    $siteInput.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            if ((SubmitForm) -eq $true) {
                $popup.Close()
            }
        }
    })
    $popup.Controls.Add($siteInput)

    $departmentLabel = New-Object System.Windows.Forms.Label
    $departmentLabel.Text = "Department"
    $departmentLabel.Location = New-Object System.Drawing.Size(20, 110)
    $departmentLabel.Size = New-Object System.Drawing.Size(80,20)
    $departmentLabel.Font = $SecondaryFont
    $popup.Controls.Add($departmentLabel)

    $departmentInput = New-Object System.Windows.Forms.TextBox
    $departmentInput.Location = New-Object System.Drawing.Size(120,110)
    $departmentInput.Size = New-Object System.Drawing.Size(215,20)
    $departmentInput.Text = ""
    $departmentInput.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            if ((SubmitForm) -eq $true) {
                $popup.Close()
            }
        }
    })
    $popup.Controls.Add($departmentInput)

    $deviceTypeLabel = New-Object System.Windows.Forms.Label
    $deviceTypeLabel.Text = "Device Type"
    $deviceTypeLabel.Location = New-Object System.Drawing.Size(20, 135)
    $deviceTypeLabel.Size = New-Object System.Drawing.Size(80,20)
    $deviceTypeLabel.Font = $SecondaryFont
    $popup.Controls.Add($deviceTypeLabel)

    $deviceTypeInput = New-Object System.Windows.Forms.TextBox
    $deviceTypeInput.Location = New-Object System.Drawing.Size(120,135)
    $deviceTypeInput.Size = New-Object System.Drawing.Size(215,20)
    $deviceTypeInput.Text = ""
    $deviceTypeInput.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") {
            if ((SubmitForm) -eq $true) {
                $popup.Close()
            }
        }
    })
    $popup.Controls.Add($deviceTypeInput)

    $requiredLabel = New-Object System.Windows.Forms.Label
    $requiredLabel.Text = "* = Required"
    $requiredLabel.TextAlign = "MiddleCenter"
    $requiredLabel.Location = New-Object System.Drawing.Size(0, 160)
    $requiredLabel.Size = New-Object System.Drawing.Size(350,20)
    $requiredLabel.Font = $SecondaryFont
    $popup.Controls.Add($requiredLabel)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(20, 180)
    $okButton.Size = New-Object System.Drawing.Size(315,50)
    $okButton.Text = "OK"
    $okButton.Font = $PrimaryFont
    $okButton.Add_Click({
        if ((SubmitForm) -eq $true) {
            $popup.Close()
        }
    })
    $popup.Controls.Add($okButton)

    $popup.ShowDialog()
    
}

function VerifyForm {

    if ($companyInput.Text -eq "") {
        $companyInput.BackColor = "yellow"
        return $false
    }
    try {
        $Script:company = ($companyInput.Text).ToUpper()
        $Script:site = ($siteInput.Text).ToUpper()
        $Script:department = ($departmentInput.Text).ToUpper()
        $Script:deviceType = ($deviceTypeInput.Text).ToUpper()
        return $true
    } catch {
        return $false
    }
}
function SubmitForm {

    if ((VerifyForm) -ne $true) {
        return
    }

    try {
        $Console.AppendText("`r`nDownloading...")

        $urlSafeCompany = [uri]::EscapeDataString($company)
        $urlSafeSite = [uri]::EscapeDataString($site)
        $urlSafeDepartment = [uri]::EscapeDataString($department)
        $urlSafeDeviceType = [uri]::EscapeDataString($deviceType)
        $url = "https://my.aspire-it.net/Bin/ConnectWiseControl.ClientSetup.exe?h=my.aspire-it.net&p=8041&k=BgIAAACkAABSU0ExAAgAAAEAAQCj8wgfBe3jCNxLcoKqDEKgbt8yZp0OQH3Ou%2FaFk0FpGWuV4xtl%2FMLDV6EsR1UIcSnXlbjc%2BsWBTVo5Iz7BsgsgyykHj%2FLVFxfyQOtN7TQ%2BI4TSQdAHW%2Bppb%2Bq3MznfQEd0AltrrPEckK58ewOaHcu7Bbs9QGc4KFJvWX0bZiC3apCpmcKthpo3wn3Buw1t9HnolgcTaNtbcnnQ%2Ff64nGPBg1XJX72I2XzJTFAztD8KoKURkYKn9hQwtCZ3bp9U3H8Sk97uzMs9Y4Xo7fGrbGObFQfPSEniKvkgii48heBrAIQjQUdCW1RIgpQCSpys%2FEpnWL3wvj%2F18F8%2BBGelqqHH&e=Access&y=Guest&t=&c=$($urlSafeCompany)&c=$($urlSafeSite)&c=$($urlSafeDepartment)&c=$($urlSafeDeviceType)&c=&c=&c=&c="
        $fileName = $company
        if ($site -ne "") {
            $fileName += "~$($site)"
        }
        if ($department -ne "") {
            $fileName += "~$($department)"
        }
        if ($deviceType -ne "") {
            $fileName += "~$($deviceType)"
        }

        $fileOut = "C:\SOFTWARE\$($fileName) SC Client.exe"

        if (!(Get-Item "C:\SOFTWARE" -ErrorAction SilentlyContinue)) {
            New-Item "C:\SOFTWARE" -ItemType Directory
        }
        
        Invoke-WebRequest -Uri $url -OutFile $fileOut

        $Console.AppendText("`r`nRunning installer...")

        Start-Process $fileOut

        $Console.AppendText("`r`nSuccess")
        return $true
    }
    catch {
        $Console.AppendText("`r`nFailed")
        return $false
    }
}

Export-ModuleMember -Function Install-ScreenConnect