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

    $popup = New-Object System.Windows.Forms.Form
    $popup.Text = "ScreenConnect Group"
    $popup.AutoSize = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "ScreenConnect Group"
    $label.TextAlign = "MiddleCenter"
    $label.Location = New-Object System.Drawing.Size(0, 0)
    $label.Size = New-Object System.Drawing.Size(350,50)
    $label.Font = $PrimaryFont
    $popup.Controls.Add($label)

    $destinationGroupInput = New-Object System.Windows.Forms.RichTextBox
    $destinationGroupInput.Location = New-Object System.Drawing.Size(20,60)
    $destinationGroupInput.Size = New-Object System.Drawing.Size(315,20)
    $destinationGroupInput.Text = ""
    $popup.Controls.Add($destinationGroupInput)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(20, 100)
    $okButton.Size = New-Object System.Drawing.Size(315,50)
    $okButton.Text = "OK"
    $okButton.Font = $PrimaryFont
    $okButton.Add_Click({
        $Script:group = $destinationGroupInput.Text
        $popup.Close()
    })
    $popup.Controls.Add($okButton)

    $popup.ShowDialog()
    
    try {
        $Console.AppendText("`r`nDownloading...")

        $urlSafeGroup = [uri]::EscapeDataString($group)
        $url = "https://my.aspire-it.net/Bin/ConnectWiseControl.ClientSetup.exe?h=my.aspire-it.net&p=8041&k=BgIAAACkAABSU0ExAAgAAAEAAQCj8wgfBe3jCNxLcoKqDEKgbt8yZp0OQH3Ou%2FaFk0FpGWuV4xtl%2FMLDV6EsR1UIcSnXlbjc%2BsWBTVo5Iz7BsgsgyykHj%2FLVFxfyQOtN7TQ%2BI4TSQdAHW%2Bppb%2Bq3MznfQEd0AltrrPEckK58ewOaHcu7Bbs9QGc4KFJvWX0bZiC3apCpmcKthpo3wn3Buw1t9HnolgcTaNtbcnnQ%2Ff64nGPBg1XJX72I2XzJTFAztD8KoKURkYKn9hQwtCZ3bp9U3H8Sk97uzMs9Y4Xo7fGrbGObFQfPSEniKvkgii48heBrAIQjQUdCW1RIgpQCSpys%2FEpnWL3wvj%2F18F8%2BBGelqqHH&e=Access&y=Guest&t=&c=$($urlSafeGroup)"
        $fileOut = "C:\SOFTWARE\$($group) SC Client.exe"

        if (!(Get-Item "C:\SOFTWARE" -ErrorAction SilentlyContinue)) {
            New-Item "C:\SOFTWARE" -ItemType Directory
        }
        
        Invoke-WebRequest -Uri $url -OutFile $fileOut

        $Console.AppendText("`r`nRunning installer...")

        Start-Process $fileOut

        $Console.AppendText("`r`nSuccess")
    }
    catch {
        $Console.AppendText("`r`nFailed")
    }
    
}

Export-ModuleMember -Function Install-ScreenConnect