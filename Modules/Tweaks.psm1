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

    $Console.AppendText("`r`nDisabling hibernation")
    try {
        powercfg.exe /H off
        $Console.AppendText("`r`n`tSuccess")
    }
    catch {
        $Console.AppendText("`r`n`tFailed")
    }

    $Console.AppendText("`r`nDisabling sleep button")
    try {
        powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
        powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
        $Console.AppendText("`r`n`tSuccess")
    }
    catch {
        $Console.AppendText("`r`n`tFailed")
    }

    $Console.AppendText("`r`nDisabling wake timers")
    try {
        powercfg -setacvalueindex SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 0
        powercfg -setdcvalueindex SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 0
        $Console.AppendText("`r`n`tSuccess")
    }
    catch {
        $Console.AppendText("`r`n`tFailed")
    }

    $Console.AppendText("`r`nDisabling USB selective suspend")
    try {
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
        powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
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