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
            $RemotePath = "\\$($computer.name)\c$\Software\$($software.Name)"
            if (Get-Item $RemotePath) {
                $Console.AppendText("$($Name) is already present on $($computer.name)")
            } else {
                $Console.AppendText("`r`nDistributing to $($computer.name)...")
                Copy-Item -Path $software.FullName -Destination "\\$($computer.name)\c$\Software\$($software.Name)"

                $Console.AppendText("`r`nInstalling on $($computer.name)...")
                Invoke-Command -ComputerName $computer.name -ScriptBlock {
                    if ($software.Extension -eq "msi") {
                        Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Software\$($software.Name) /quiet'
                    } else {
                        Start-Process "C:\Software\$($software.Name)" -Wait
                    }
                }

                $count++
            }
        }

        $Console.AppendText("`r`nDistributed to $($count) computers!")

    } else {
        $Console.AppendText("`r`n`r`nDid not find $($Name)... `r`nPlease place installer in $($Path)... `r`nInstaller name must include `"$($Name)`"")
    }
    
}

Export-ModuleMember -Function Distribute-Software