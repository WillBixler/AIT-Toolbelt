function Distribute-Software {
    param (
        [System.Windows.Forms.RichTextBox]$Console,
        $Path,
        $Name,
        $Destination
    )

    $Console.Clear()
    $Console.AppendText("Searching for $($Name) installer in C:\Software")
    if ($software = Get-Item -Path "$($Path)\*$($Name)*") {
        $Console.AppendText("`r`n`r`nFound $($software.BaseName) in $($software.Directory)")
        
        $Console.AppendText("`r`n`r`nDistributing $($Name)...")

        $count = 0
        foreach($computer in Get-ADComputer -Filter *) {
            $Console.AppendText("`r`nDistributing to $($computer.name)...")
            Copy-Item -Path $software.FullName -Destination "\\$($computer.name)\c$\Software\$($software.Name)"
            $count++
        }

        $Console.AppendText("`r`nDistributed to $($count) computers!")

    } else {
        $Console.AppendText("`r`n`r`nDid not find $($Name)... `r`nPlease place installer in $($Path)... `r`nInstaller name must include `"$($Name)`"")
    }
    
}

Export-ModuleMember -Function Distribute-Software