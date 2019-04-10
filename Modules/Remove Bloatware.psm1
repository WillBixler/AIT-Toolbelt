function Remove-Bloatware {

	param(
		[System.Windows.Forms.TextBox]$Console
	)

	$ProgressPreference = "SilentlyContinue"

	$bloatware = @("Amazon", "Bing", "HeartsDeluxe", "Mahjong", "Messaging", "Netflix", "OneConnect", "OneNote", "People", "Print3D", "RandomSaladGames", "Snapfish", "Solitaire", "TheWeatherChannel", "TripAdvisor", "Wallet", "Xbox", "Zune")
	$ignore = @("Microsoft.XboxGameCallableUI", "Microsoft.Windows.PeopleExperienceHost")

	$count = 0

	$Console.Text = "Removing bloatware..."

	foreach($app in $bloatware) {
		if (get-appxpackage *$app*) {
			get-appxpackage *$app* | ForEach-Object {
				if (!$ignore.Contains($_.name)) {
					$Console.Text += "`r`nRemoving $($_.name)"
					get-appxpackage "`r`n$($_.name)" | remove-appxpackage -ErrorAction SilentlyContinue
					$count++
				}
			}
		} else {
			$Console.Text += "`r`n$($app) not installed"
		}
	}

	$Console.Text += "`r`n`r`nDone removing bloatware... Removed $($count) apps!"

}

Export-ModuleMember -Function Remove-Bloatware