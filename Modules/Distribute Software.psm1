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
        $Console.AppendText("`r`nPlease switch to the PowerShell console for progress...")

        $Computers = Get-NetworkComputers
        $Successful = @()
        $Failed = @()

        foreach($computer in $Computers) {
            $computerName = $computer.Path.Split("/")[3]
            Write-Host "`r`n`r`nDistributing to $($computerName)..." -ForegroundColor Yellow

            try {
                Copy-Item -Path $Path -Destination "\\$($computerName)\c$\SOFTWARE\$($FileName)" -ErrorAction Stop
                Write-Host "Copied sucessfully..." -ForegroundColor Green
                Write-Host "Starting software on $($computerName)..." -ForegroundColor Yellow
                $session = New-PSSession -ComputerName $computerName -ErrorAction SilentlyContinue
                if ($session -ne $null) {
                    Invoke-Command -Session $session -ScriptBlock {
                        try {
                            if ($software.Extension -eq "msi") {
                                Start-Process msiexec.exe -ArgumentList '/I C:\Software\$($software.Name) /quiet' -ErrorAction Stop
                            } else {
                                Start-Process "C:\Software\$($software.Name)" -ErrorAction Stop
                            }
                        } catch {
                            return $_
                        }
                    }
                    Write-Host "Software successfully started!" -ForegroundColor Green
                    $Successful += $computerName
                } else {
                    $ErrorMessage = "Connection Failed"
                    Write-Host "Connection to $computerName failed... Please run `"winrm quickconfig`" in powershell on $computerName" -ForegroundColor Red
                    $Failed += "$($computerName) - $($ErrorMessage)"
                }
            } catch [System.UnauthorizedAccessException] {
                $ErrorMessage = "Access Denied"
                Write-Host $ErrorMessage -ForegroundColor Red
                $Failed += "$($computerName) - $($ErrorMessage)"
            } catch [System.Runtime.InteropServices.COMException] {
                if (Test-Connection $RemoteComputerName -Count 1 -Quiet) {
                    $ErrorMessage = "RPC server unavailable"
                    Write-Host $ErrorMessage -ForegroundColor Red
                } else {
                    $ErrorMessage = "Offline"
                    Write-Host $ErrorMessage -ForegroundColor Red
                }
                $Failed += "$($computerName) - $($ErrorMessage)"
            } catch [System.Management.ManagementException] {
                $ErrorMessage = "User credentials cannot be used for local connections"
                Write-Host $ErrorMessage -ForegroundColor Red
                $Failed += "$($computerName) - $($ErrorMessage)"
            } catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "Unknown Error - $($_.Exception.Message) | $($_.Exception.GetType())" -ForegroundColor Red
                $Failed += "$($computerName) - $($ErrorMessage)"
            }
        }

        Write-Host "`r`nDone... Please switch back to the GUI window..."

        $Console.AppendText("`r`nSuccessfully distributed to $($Successful.count) computers:")
        foreach($computer in $Successful) {
            $Console.AppendText("`r`n$($computer)")
        }

        $Console.AppendText("`r`n`r`nFailed to distribute to $($Failed.count) computers:")
        foreach($computer in $Failed) {
            $Console.AppendText("`r`n$($computer)")
        }
    }
}

Export-ModuleMember -Function Distribute-Software