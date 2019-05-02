Import-Module "$PSScriptRoot\Network Computers.psm1" -Force

function Distribute-Software {
    param (
        [System.Windows.Forms.RichTextBox]$Console,
        $Destination
    )

    $Console.Clear()

    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
    }
    $FileBrowser.ShowDialog()

    $Path = $FileBrowser.FileName
    $FileName = $FileBrowser.SafeFileName
    $Console.AppendText("File: $($FileName)")

    if (Get-Item -Path $Path) {

        $Console.AppendText("`r`n`r`nFinding Network Computers...")
        
        $Console.AppendText("`r`n`r`nDistributing $($FileBrowser.SafeFileName)... This can take a while...")

        $Computers = Get-NetworkComputers

        foreach($computer in $Computers) {
            $computerName = $computer.Path.Split("/")[3]
            $Console.AppendText("`r`nDistributing to $($computerName)...")
            
            Copy-Item -Path $Path -Destination "\\$($computerName)\c$\SOFTWARE\$($FileName)" -ErrorAction SilentlyContinue
            
        }

        <#$count = 0
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
        }#>

    }
    
}

Export-ModuleMember -Function Distribute-Software