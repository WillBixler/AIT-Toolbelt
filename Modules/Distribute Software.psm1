Import-Module "$PSScriptRoot\Network Computers.psm1" -Force

function Distribute-Software {
    param (
        [System.Windows.Forms.RichTextBox]$Console
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

        $PrimaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Regular)
        $SecondaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)

        $popup = New-Object System.Windows.Forms.Form
        $popup.Text = "Network Computers"
        $popup.AutoSize = $true

        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Computers To Distribute Software To"
        $label.TextAlign = "MiddleCenter"
        $label.Location = New-Object System.Drawing.Size(0, 0)
        $label.Size = New-Object System.Drawing.Size(350,50)
        $label.Font = $PrimaryFont
        $popup.Controls.Add($label)

        $CheckedListBox = New-Object System.Windows.Forms.CheckedListBox
        $CheckedListBox.Size = New-Object System.Drawing.Size(350,500)
        $CheckedListBox.Location = New-Object System.Drawing.Size(0, 50)
        $CheckedListBox.Font = $SecondaryFont
        $CheckedListBox.CheckOnClick = $true

        $popup.Controls.Add($CheckedListBox)

        $destinationFolderLabel = New-Object System.Windows.Forms.Label
        $destinationFolderLabel.Location = New-Object System.Drawing.Size(0, 550)
        $destinationFolderLabel.Size = New-Object System.Drawing.Size(100,25)
        $destinationFolderLabel.Text = "Destination Folder"
        $popup.Controls.Add($destinationFolderLabel)

        $destinationFolderInput = New-Object System.Windows.Forms.RichTextBox
        $destinationFolderInput.Location = New-Object System.Drawing.Size(0,575)
        $destinationFolderInput.Size = New-Object System.Drawing.Size(320,20)
        $destinationFolderInput.Text = "C:\SOFTWARE"
        $popup.Controls.Add($destinationFolderInput)

        $destinationFolderButton = New-Object System.Windows.Forms.Button
        $destinationFolderButton.Location = New-Object System.Drawing.Size(330, 575)
        $destinationFolderButton.Size = New-Object System.Drawing.Size(25, 20)
        $destinationFolderButton.Text = "..."
        $destinationFolderButton.Add_click({

            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $FolderBrowser.ShowDialog()

            $destinationFolderInput.Text = $FolderBrowser.SelectedPath
        })
        $popup.Controls.Add($destinationFolderButton)

        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Size(0, 600)
        $okButton.Size = New-Object System.Drawing.Size(350,50)
        $okButton.Text = "OK"
        $okButton.Font = $PrimaryFont
        $okButton.Add_Click({
            $Script:CheckedComputers = $CheckedListBox.CheckedItems
            $Script:DestinationFolder = $destinationFolderInput.Text
            $popup.Close()
        })
        $popup.Controls.Add($okButton)

        foreach($computer in $Computers) {
            $computerName = $computer.Path.Split("/")[3]
            $CheckedListBox.Items.Add($computerName)
        }

        $popup.ShowDialog()

        foreach($computer in $CheckedComputers) {
            Write-Host "`r`n`r`nDistributing to $($computer)..." -ForegroundColor Yellow

            try {
                $destinationPath = "\\$($computer)\$($DestinationFolder -replace ":", "$")\$($FileName)"
                Write-Host "Destination: $($destinationPath)"
                Copy-Item -Path $Path -Destination $destinationPath -Recurse -ErrorAction Stop
                Write-Host "Copied sucessfully..." -ForegroundColor Green
                Write-Host "Enabling PS Remoting on $($computer)..." -ForegroundColor Yellow
                Set-Location $PSScriptRoot
                ..\PSTools\psexec \\$computer -h -accepteula -nobanner powershell.exe "enable-psremoting -force"
                Write-Host "Starting software on $($computer)..." -ForegroundColor Yellow
                $session = New-PSSession -ComputerName $computer -ErrorAction SilentlyContinue
                if ($session -ne $null) {
                    Invoke-Command -Session $session -ScriptBlock {
                        param(
                            $path,
                            $fileName,
                            $DestinationFolder
                        )
                        if ((Get-Item "$($DestinationFolder)\$($fileName)").Extension -eq "msi") {
                            Start-Process msiexec.exe -ArgumentList '/I $($DestinationFolder)\$($fileName) /quiet' -ErrorAction Stop
                        } else {
                            Start-Process "$($DestinationFolder)\$($fileName)" -ArgumentList "/silent", "/s", "/q", "/quiet", "--silent" -ErrorAction Stop
                        }
                    } -ArgumentList $Path, $FileName, $DestinationFolder
                    Write-Host "Software successfully started!" -ForegroundColor Green
                    $Successful += $computer
                } else {
                    $ErrorMessage = "Connection Failed"
                    Write-Host "Connection to $computer failed... Please run `"Enable-PSRemoting`" in powershell on $computer" -ForegroundColor Red
                    $Failed += "$($computer) - $($ErrorMessage)"
                }
                Exit-PSSession
            } catch [System.UnauthorizedAccessException] {
                $ErrorMessage = "Access Denied"
                Write-Host $ErrorMessage -ForegroundColor Red
                $Failed += "$($computer) - $($ErrorMessage)"
            } catch [System.Runtime.InteropServices.COMException] {
                if (Test-Connection $RemoteComputerName -Count 1 -Quiet) {
                    $ErrorMessage = "RPC server unavailable"
                    Write-Host $ErrorMessage -ForegroundColor Red
                } else {
                    $ErrorMessage = "Offline"
                    Write-Host $ErrorMessage -ForegroundColor Red
                }
                $Failed += "$($computer) - $($ErrorMessage)"
            } catch [System.Management.ManagementException] {
                $ErrorMessage = "User credentials cannot be used for local connections"
                Write-Host $ErrorMessage -ForegroundColor Red
                $Failed += "$($computer) - $($ErrorMessage)"
            } catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "Unknown Error - $($_.Exception.Message) | $($_.Exception.GetType())" -ForegroundColor Red
                $Failed += "$($computer) - $($ErrorMessage)"
            }
        }

        Write-Host "`r`nDone... Please switch back to the GUI window..."

        $Console.AppendText("`r`n`r`nSuccessfully distributed to $($Successful.count) computers:")
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