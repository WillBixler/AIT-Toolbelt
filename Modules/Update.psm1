Function Update {

	param(
        [System.Windows.Forms.RichTextBox]$Console,
        $ScriptRoot,
        $CurrentVersion
    )

    $tempGit = $false

    $Console.Clear()

    $Console.AppendText("Updating...")

    $Console.AppendText("`r`n`r`nChecking Git installation...")
    $gitInstalled = Get-Command -ErrorAction SilentlyContinue git
    if (!$gitInstalled) {
        $Console.AppendText("`r`nGit not installed... Downloading...")

        $tempGit = $true
        $url = "https://github.com/git-for-windows/git/releases/download/v2.24.1.windows.2/Git-2.24.1.2-64-bit.exe"
        $fileOut = "C:\SOFTWARE\Git.exe"

        if (!(Get-Item "C:\SOFTWARE" -ErrorAction SilentlyContinue)) {
            New-Item "C:\SOFTWARE" -ItemType Directory
        }

        if (!(Get-Item $fileOut -ErrorAction SilentlyContinue)) {
            Invoke-WebRequest -Uri $url -OutFile $fileOut
        }

        Start-Process $fileOut /silent -Wait
    } else {
        $Console.AppendText("`r`nGit installed... Updating...")
    }

    Set-Location $ScriptRoot
    $Console.AppendText("`r`n`r`nFinding local changes...")
    Start-Process "C:\Program Files\Git\git-cmd.exe" -ArgumentList { "git add . && git commit -m 'ff' && git fetch --all && git reset --hard origin/master && exit" } -Wait
    $Console.AppendText("`r`nFinding and installing updates...")
    Start-Process "C:\Program Files\Git\git-cmd.exe" -ArgumentList { "git pull && exit" } -Wait

    $NewVersion = (Get-Content "$ScriptRoot\Info.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Version
    
    if ($tempGit) {
        $Console.AppendText("`r`nRemoving temp git...")
        $GitRegKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "Git*" }
        Start-Process $GitRegKey.UninstallString /Silent -Wait
    }

    $Console.AppendText("`r`n`r`nDone!")
    if ($CurrentVersion -like $NewVersion) {
        $Console.AppendText("`r`nNo updates found.")
        return $false
    } else {
        $Console.AppendText("`r`n`r`nUpdated from $($CurrentVersion) to $($NewVersion)!")
        $Console.AppendText("`r`nRestarting in ");
        for($i = 5; $i -gt 0; $i--) {
            $Console.AppendText("$($i)... ")
            Start-Sleep 1
        }
        Start-Process Powershell.exe "$($ScriptRoot)/Toolbelt.ps1"
        return $true
    }
}

Export-ModuleMember -Function Update