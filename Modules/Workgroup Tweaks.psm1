
Function WorkgroupTweaks {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("`r`nHiding AIT Account...")
    $AIT = Get-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" | Select-Object AIT
    if ($AIT -like "*0*") {
        $Console.AppendText("`r`n`tAlready hidden")
    } else {
        try {
            New-Item -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" -ErrorAction SilentlyContinue
            New-Item -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name AIT -Value 0
            $Console.AppendText("`r`n`tSuccess")
        }
        catch {
            $Console.AppendText("`r`n`tFailed")
        }
    }

    $Console.AppendText("`r`nEnabling C$ Share...")
    $CShare = Get-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object LocalAccountTokenFilterPolicy
    if ($CShare -like "*1*") {
        $Console.AppendText("`r`n`tAlready enabled")
    } else {
        try {
            Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 1
            $Console.AppendText("`r`n`tSuccess")
        }
        catch {
            $Console.AppendText("`r`n`tFailed")
        }
    }

    $Console.AppendText("`r`n`r`nRestarting Windows Explorer...")
    Stop-Process -ProcessName explorer

    $Console.AppendText("`r`n`r`nDone!")
}

Export-ModuleMember -Function WorkgroupTweaks