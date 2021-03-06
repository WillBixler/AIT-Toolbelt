function Install-Pulseway {
    param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Installing Pulseway...")
    $Console.AppendText("`r`nChecking for previous installations...")
    
    $pw = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "Pulseway" }

    if ($null -ne $pw) {
        $Console.AppendText("`r`nPulseway already installed")
        return
    }
    
    $Console.AppendText("`r`n`tNo installation found")
    
    try {
        $Console.AppendText("`r`nDownloading...")

        $url = "https://www.pulseway.com/download/Pulseway_x64.msi"
        $fileOut = "C:\SOFTWARE\PW Installer.msi"

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

Export-ModuleMember -Function Install-Pulseway