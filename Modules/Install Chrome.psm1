function Install-Chrome {
    param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Installing Google Chrome...")
    $Console.AppendText("`r`nChecking for previous installations...")
    
    $chrome = Get-Item "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -ErrorAction SilentlyContinue

    if ($null -ne $chrome) {
        $Console.AppendText("`r`nGoogle Chrome is already installed")
        return
    }
    
    $Console.AppendText("`r`n`tNo installation found")
    
    try {
        $Console.AppendText("`r`nDownloading...")

        $url = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B89A9E3AD-8AB9-1A19-304B-EB61A2B9E739%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26brand%3DCHBD%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
        $fileOut = "C:\SOFTWARE\ChromeSetup.exe"

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

Export-ModuleMember -Function Install-Chrome