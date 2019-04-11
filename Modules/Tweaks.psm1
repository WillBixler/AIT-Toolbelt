Function Tweaks {

	param(
		[System.Windows.Forms.RichTextBox]$Console
    )

    $Console.Clear()

    $Console.AppendText("Setting UAC...")
    Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
    
    $Console.AppendText("`r`nRemoving Start Menu Pins...")
    (New-Object -Com Shell.Application). NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}'). Items() | ForEach-Object{ $_.Verbs() } | Where-Object{$_.Name -match 'Un.*pin from Start'} | ForEach-Object{$_.DoIt()}

    # Adjust Sleep Settings
    $Console.AppendText("`r`nUpdating power settings...")
    powercfg.exe /X standby-timeout-ac 0
    powercfg.exe /X standby-timeout-dc 0

    $Console.AppendText("`r`n`r`nDone!")
}

Export-ModuleMember -Function Tweaks