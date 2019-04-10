Function Tweaks {

	param(
		[System.Windows.Forms.TextBox]$Console
	)
    
    $Console.Text = "Removing Start Menu Pins..."
    (New-Object -Com Shell.Application). NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}'). Items() | ForEach-Object{ $_.Verbs() } | Where-Object{$_.Name -match 'Un.*pin from Start'} | ForEach-Object{$_.DoIt()}
    $Console.Text += "`r`nStart Menu Pins Removed"

}

Export-ModuleMember -Function Tweaks