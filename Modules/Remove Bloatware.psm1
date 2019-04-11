function Remove-Bloatware {

	param(
		[System.Windows.Forms.RichTextBox]$Console
	)

	$ProgressPreference = "SilentlyContinue"

	$bloatware = @("Amazon", "Bing", "HeartsDeluxe", "Mahjong", "Messaging", "Netflix", "OneConnect", "OneNote", "People", "Print3D", "RandomSaladGames", "Snapfish", "Solitaire", "TheWeatherChannel", "TripAdvisor", "Wallet", "Xbox", "Zune")
	$ignore = @("Microsoft.XboxGameCallableUI", "Microsoft.Windows.PeopleExperienceHost")

	$count = 0

	$Console.Clear()
	$Console.AppendText("Removing bloatware...")

	foreach($app in $bloatware) {
		if (get-appxpackage *$app*) {
			get-appxpackage *$app* | ForEach-Object {
				if (!$ignore.Contains($_.name)) {
					$Console.AppendText("`r`nRemoving $($_.name)")
					get-appxpackage "$($_.name)" | remove-appxpackage -ErrorAction SilentlyContinue
					$count++
				}
			}
		} else {
			$Console.AppendText("`r`n$($app) not installed")
		}
	}

	$Console.AppendText("`r`n`r`nDone removing bloatware... Removed $($count) apps!")

}

Export-ModuleMember -Function Remove-Bloatware