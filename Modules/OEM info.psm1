Function Set-OEM {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.AppendText("`r`n`r`nFilling OEM Info...")
    $OEM = Get-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation
    if (!$OEM.Manugacturer) {
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name Manufacturer "Aspire IT"
    }
    if (!$OEM.SupportPhone) {
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name SupportPhone "303-250-0678"
    }
    if (!$OEM.SupportURL) {
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name SupportURL "https://www.aspire-it.net/"
    }

}

Export-ModuleMember -Function Set-OEM