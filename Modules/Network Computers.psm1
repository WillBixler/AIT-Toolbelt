function Get-NetworkCredentials {
    # Get network credentials

    Add-Type -assembly System.Windows.Forms
    $CredentialsForm = New-Object System.Windows.Forms.Form
    $CredentialsForm.Text = "Network Administrator Credentials"
    $CredentialsForm.Width = 320
    $CredentialsForm.Height = 200
    $CredentialsForm.AutoSize = $true
    $CredentialsForm.StartPosition = "CenterScreen"

    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Location = New-Object System.Drawing.Size(10,20)
    $instructionsLabel.Size = New-Object System.Drawing.Size(300,30)
    $instructionsLabel.Text = "Please input the network administrator`'s login credentials."
    $CredentialsForm.Controls.Add($instructionsLabel)

    $UnLabel = New-Object System.Windows.Forms.Label
    $UnLabel.Location = New-Object System.Drawing.Size(10,50)
    $UnLabel.Size = New-Object System.Drawing.Size(80,30)
    $UnLabel.Text = "Username:"
    $CredentialsForm.Controls.Add($UnLabel)

    $PwLabel = New-Object System.Windows.Forms.Label
    $PwLabel.Location = New-Object System.Drawing.Size(10,80)
    $PwLabel.Size = New-Object System.Drawing.Size(80,30)
    $PwLabel.Text = "Password:"
    $CredentialsForm.Controls.Add($PwLabel)

    $UnInput = New-Object System.Windows.Forms.TextBox
    $UnInput.Location = New-Object System.Drawing.Size(100,50)
    $UnInput.Size = New-Object System.Drawing.Size(200,20)
    $UnInput.Text = "$($env:USERDNSDOMAIN)\$($env:USERNAME)"
    $CredentialsForm.Controls.Add($UnInput)

    $PwInput = New-Object System.Windows.Forms.MaskedTextBox
    $PwInput.PasswordChar = "*"
    $PwInput.Location = New-Object System.Drawing.Size(100,80)
    $PwInput.Size = New-Object System.Drawing.Size(200,20)
    $CredentialsForm.Controls.Add($PwInput)

    $OkButton = New-Object System.Windows.Forms.Button
    $OkButton.Location = New-Object System.Drawing.Size(160,120)
    $OkButton.Size = New-Object System.Drawing.Size(130,30)
    $OkButton.Text = "OK"
    $OkButton.Add_Click({
        $script:inputUN = $UnInput.Text
        $script:inputPW = $PwInput.Text
        $CredentialsForm.Close()
    })
    $CredentialsForm.Controls.Add($OkButton)

    [void]$CredentialsForm.ShowDialog()

    $AdminAccount = $inputUN
    $AdminPassword = ConvertTo-SecureString $inputPW -AsPlainText -Force
    return $credentials = New-Object System.Management.Automation.PSCredential $AdminAccount, $AdminPassword

}

function Get-NetworkComputers {

    # Get computers

    Write-Host "Getting network computers... This can take a while..." -ForegroundColor Green
    return $networkComputers = (([adsi]"WinNT://$((Get-WMIObject Win32_ComputerSystem).Domain)").Children).Where({$_.schemaclassname -eq 'computer'})
    
}

Export-ModuleMember -Function *