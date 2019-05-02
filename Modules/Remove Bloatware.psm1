function Remove-Bloatware {

	param(
		[System.Windows.Forms.RichTextBox]$Console
	)

	$ProgressPreference = "SilentlyContinue"

	# Definitions
	$bloatware = @("Amazon", "Bing", "HeartsDeluxe", "Mahjong", "Messaging", "Netflix", "OneConnect", "OneNote", "People", "Print3D", "RandomSaladGames", "Snapfish", "Solitaire", "TheWeatherChannel", "TripAdvisor", "Wallet", "Xbox", "Zune")
	$ignore = @("Microsoft.XboxGameCallableUI", "Microsoft.Windows.PeopleExperienceHost")

	# Count of removed bloatware
	$count = 0

	# Reset console
	$Console.Clear()
	$Console.AppendText("Removing bloatware...")

	# For each app in bloatware definitions
	foreach($app in $bloatware) {
		# If there are apps that match the pattern
		if (get-appxpackage *$app*) {
			# For each found app that matches
			get-appxpackage *$app* | ForEach-Object {
				# If the app is not in the ignore list
				if (!$ignore.Contains($_.name)) {
					# Remove the app and increment the count
					$Console.AppendText("`r`nRemoving $($_.name)")
					get-appxpackage -AllUsers "$($_.name)" | remove-appxpackage -ErrorAction SilentlyContinue
					$count++
				}
			}
		# Bloatware app not installed on machine
		} else {
			$Console.AppendText("`r`n$($app) not installed")
		}
	}

	$Console.AppendText("`r`n`r`nDone removing bloatware... Removed $($count) apps!")

}

Export-ModuleMember -Function Remove-Bloatware