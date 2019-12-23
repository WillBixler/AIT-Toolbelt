function Install-AcrobatReader {
    param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Installing Adobe Acrobat Reader DC...")
    $Console.AppendText("`r`nChecking for previous installations...")
    
    $pw = Get-Item "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe" -ErrorAction SilentlyContinue

    if ($null -ne $pw) {
        $Console.AppendText("`r`nAdobe Acrobat Reader DC is already installed")
        return
    }
    
    $Console.AppendText("`r`n`tNo installation found")
    
    try {
        $Console.AppendText("`r`nDownloading...")

        $url = "https://admdownload.adobe.com/bin/live/readerdc_en_xa_cra_install.exe"
        $fileOut = "C:\SOFTWARE\AdobeReader.msi"

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

Export-ModuleMember -Function Install-AcrobatReader