Function Tweaks {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Disabling UAC...")
    $UAC = Get-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System | Select-Object ConsentPromptBehaviorAdmin
    if ($UAC -like "*0*") {
        $Console.AppendText("`r`n`tAlready disabled")
    } else {
        try {
            Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
            $Console.AppendText("`r`n`tSuccess")
        }
        catch {
            $Console.AppendText("`r`n`tFailed")
        }
    }
    
    
    $Console.AppendText("`r`n`r`nRemoving Start Menu Pins...")
    (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ForEach-Object{ $_.Verbs() } | Where-Object{$_.Name -match 'Un.*pin from Start'} | ForEach-Object{$_.DoIt()}

    # Adjust Power
    
    $Console.AppendText("`r`n`r`nImporting `"Ultimate`" power plan.")
    $currentPlan = powercfg.exe /getActiveScheme
    if ($currentPlan -like "*Ultimate Performance*") {
        $Console.AppendText("`r`n`tAlready active")
    } else {
        try {
            $Ultimate = powercfg -l | ForEach-Object{if($_.contains("Ultimate Performance")) {$_.split()[3]}}
            if ($null -eq $Ultimate) {
              powercfg.exe -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
              $Ultimate = powercfg -l | ForEach-Object{if($_.contains("Ultimate Performance")) {$_.split()[3]}}
            }
            powercfg.exe /setactive $Ultimate
            $Console.AppendText("`r`n`tImported Successfully")
        }
        catch {
            $Console.AppendText("`r`n`tImport Failed")
        }
    }

    $Console.AppendText("`r`nSetting sleep times")
    try {
        powercfg.exe /X standby-timeout-ac 0
        powercfg.exe /X standby-timeout-dc 0
        powercfg.exe /X monitor-timeout-ac 30
        powercfg.exe /X monitor-timeout-dc 30
        $Console.AppendText("`r`n`tSuccess")
    }
    catch {
        $Console.AppendText("`r`n`tFailed")
    }

    $Console.AppendText("`r`nDisabling network adapter power management...")
    $adapters = Get-NetAdapter -Physical | Get-NetAdapterPowerManagement
    $adapters | ForEach-Object {
        if ($_.AllowComputerToTurnOffDevice -like "*Disabled*") {
            $Console.AppendText("`r`n`t$($_.InterfaceDescription)")
            $Console.AppendText("`r`n`t`tAlready Disabled")
        } else {
            try {
                $_.AllowComputerToTurnOffDevice = 'Disabled'
                $_ | Set-NetAdapterPowerManagement -ErrorAction Stop
                $Console.AppendText("`r`n`t$($_.InterfaceDescription)")
                $Console.AppendText("`r`n`t`tSuccess")
            } catch {
                $Console.AppendText("`r`n`t$($_.InterfaceDescription)")
                $Console.AppendText("`r`n`t`tFailed")
            }
        }
    }

    $Console.AppendText("`r`n`r`nDone!")
}

Export-ModuleMember -Function Tweaks