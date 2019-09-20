Function Tweaks {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Disabling UAC...")
    Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
    
    $Console.AppendText("`r`n`r`nRemoving Start Menu Pins...")
    (New-Object -Com Shell.Application). NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}'). Items() | ForEach-Object{ $_.Verbs() } | Where-Object{$_.Name -match 'Un.*pin from Start'} | ForEach-Object{$_.DoIt()}

    # Adjust Power
    
    $Console.AppendText("`r`n`r`nImporting `"Ultimate`" power plan.")
    $Ultimate = powercfg -l | ForEach-Object{if($_.contains("Ultimate Performance")) {$_.split()[3]}}
    if ($null -eq $Ultimate) {
      powercfg.exe -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
      $Ultimate = powercfg -l | ForEach-Object{if($_.contains("Ultimate Performance")) {$_.split()[3]}}
    }

    $Console.AppendText("`r`nSetting sleep times")
    powercfg.exe -setactive $Ultimate
    powercfg.exe /X standby-timeout-ac 0
    powercfg.exe /X standby-timeout-dc 0
    powercfg.exe /X monitor-timeout-ac 30
    powercfg.exe /X monitor-timeout-dc 30

    $Console.AppendText("`r`nDisabling network adapter power management...")
    $adapters = Get-NetAdapter -Physical | Get-NetAdapterPowerManagement
    $adapters | ForEach-Object {
        try {
            $_.AllowComputerToTurnOffDevice = 'Disabled'
            $_ | Set-NetAdapterPowerManagement -ErrorAction Stop
            $Console.AppendText("`r`n`tSuccess -  $($_.InterfaceDescription).")
        } catch {
            $Console.AppendText("`r`n`tFailed - $($_.InterfaceDescription).")
        }
    }

    $Console.AppendText("`r`n`r`nDone!")
}

Export-ModuleMember -Function Tweaks