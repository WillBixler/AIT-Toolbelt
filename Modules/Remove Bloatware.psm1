function Remove-Bloatware {

	param(
		[System.Windows.Forms.RichTextBox]$Console
	)

	$ProgressPreference = "SilentlyContinue"

	# Definitions
	$bloatware = @("Amazon", "Bing", "HeartsDeluxe", "Mahjong", "Messaging", "Netflix", "OneConnect", "OneNote", "People", "Print3D", "RandomSaladGames", "Snapfish", "Solitaire", "TheWeatherChannel", "TripAdvisor", "Wallet", "Maps", "Zune", "Skype", "YourPhone", "Xbox")
	$ignore = @("Microsoft.XboxGameCallableUI", "Microsoft.Windows.PeopleExperienceHost")
	$foundBloatware = [System.Collections.ArrayList] @()

	$removedCount = 0

	# Reset console
	$Console.Clear()
	$Console.AppendText("Scanning for bloatware...")
	foreach($app in $bloatware) {
		Get-AppxPackage *$app* | ForEach-Object {
			if (!$ignore.Contains($_.name)) {
				$foundBloatware.Add($_.name)
			}
		}
	}

	if ($foundBloatware.Count -gt 0) {
		$Console.AppendText("`r`n$($foundBloatware.Count) pieces of bloatware found...")
	} else {
		$Console.AppendText("`r`nNo bloatware found!")
		return
	}

	$PrimaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Regular)
	$SecondaryFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)

	$popup = New-Object System.Windows.Forms.Form
	$popup.Text = "Remove Bloatware"
	$popup.AutoSize = $true

	$label = New-Object System.Windows.Forms.Label
	$label.Text = "Select Bloatware to Remove"
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

	foreach($app in $foundBloatware) {
		$CheckedListBox.Items.Add($app)
		$CheckedListBox.SetItemChecked($CheckedListBox.Items.Count - 1, $true)
	}

	$popup.Controls.Add($CheckedListBox)

	$okButton = New-Object System.Windows.Forms.Button
	$okButton.Location = New-Object System.Drawing.Size(0, 600)
	$okButton.Size = New-Object System.Drawing.Size(350,50)
	$okButton.Text = "OK"
	$okButton.Font = $PrimaryFont
	$okButton.Add_Click({
		$Script:removeBloatware = $CheckedListBox.CheckedItems
		$popup.Close()
	})
	$popup.Controls.Add($okButton)

	$popup.ShowDialog()

	if ($null -eq $removeBloatware -or $removeBloatware -like "System.Windows.Forms.Button*") {
		$Console.AppendText("`r`nNo items selected for removal.")
		return
	}

	$Console.AppendText("`r`n`r`nRemoving $($removeBloatware.Count) piece(s) of bloatware...")

	foreach($app in $removeBloatware) {
		try {
			$Console.AppendText("`r`nRemoving $($app)...")
			Get-AppxPackage *$app* | Remove-AppxPackage
			$Console.AppendText("`r`n`tSUCCESS")
			$removedCount++
		} catch {
			$Console.AppendText("`r`n`t FAILED")
		}
	}

	if ($removedCount -eq 0) {
		$Console.AppendText("`r`n`r`nNo bloatware was found!")
	} else {
		$Console.AppendText("`r`n`r`nDone removing bloatware... Removed $($removedCount) apps!")
	}

}

Export-ModuleMember -Function Remove-Bloatware