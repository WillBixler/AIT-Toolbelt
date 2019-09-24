function Install-Pulseway {
    param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Installing Pulseway...")
    $Console.AppendText("`r`nChecking for previous installations...")

    if ($null -ne (Get-WmiObject Win32_Product -Filter "Name like '%Pulseway%'")) {
        $Console.AppendText("`r`nPulseway already installed")
    } else {
        $Console.AppendText("`r`n`tNo installation found")
        
        try {
            $Console.AppendText("`r`nDownloading...")
    
            $url = "https://www.pulseway.com/download/Pulseway_x64.msi"
            $fileOut = "C:\SOFTWARE\PW Installer.msi"
    
            Invoke-WebRequest -Uri $url -OutFile $fileOut
    
            $Console.AppendText("`r`nRunning installer...")
    
            Start-Process $fileOut
    
            $Console.AppendText("`r`nSuccess")
        }
        catch {
            $Console.AppendText("`r`nFailed")
        }
    }
    
}

Export-ModuleMember -Function Install-Pulseway