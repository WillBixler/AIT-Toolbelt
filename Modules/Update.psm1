Function Update {

	param(
        [System.Windows.Forms.RichTextBox]$Console,
        $ScriptRoot,
        $CurrentVersion
    )

    $Console.Clear()

    $Console.AppendText("Updating...")

    $Console.AppendText("`r`n`r`nChecking Git installation...")
    $gitInstalled = Get-Command -ErrorAction SilentlyContinue git
    if (!$gitInstalled) {
        $Console.AppendText("`r`nGit not installed... Cannot update.")
        return
    } else {
        $Console.AppendText("`r`nGit installed... Updating...")
    }

    Set-Location $ScriptRoot
    $Console.AppendText("`r`n`r`nFinding local changes...")
    git add .
    git commit -m "ff"
    git fetch --all
    git reset --hard origin/master
    $Console.AppendText("`r`nFinding and installing updates...")
    git pull

    $NewVersion = (Get-Content "$ScriptRoot\Info.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Version

    $Console.AppendText("`r`n`r`nDone!")
    if ($CurrentVersion -like $NewVersion) {
        $Console.AppendText("`r`nNo updates found.")
        return $false
    } else {
        $Console.AppendText("`r`nUpdated from $($CurrentVersion) to $($NewVersion)!")
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