Add-Type -AssemblyName System.Drawing, System.Windows.Forms

function Get-BillingHours {

    [CmdletBinding()]

    Param (

        [ValidatePattern('^[0-2][0-9][0-5][0-9]$')]
        [string]$StartTime,

        [ValidatePattern('^[0-2][0-9][0-5][0-9]$')]
        [string]$EndTime
    )

    begin {

    }

    process {
        try {
            $ConvertedStartTime = [DateTime]::ParseExact($StartTime, 'HHmm', $null)
        }
        catch {
            Write-Error -Message "StartTime: $StartTime is invalid. Please specify a correct start time in a 24 hour format." -ErrorAction Stop
        }
        try {
            $ConvertedEndTime = [DateTime]::ParseExact($EndTime, 'HHmm', $null)
        }
        catch {
            Write-Error -Message "EndTime: $EndTime is invalid. Please specify a correct start time in a 24 hour format." -ErrorAction Stop
        }
        
        $TimeDifference = $ConvertedEndTime - $ConvertedStartTime
        if ($TimeDifference.Ticks -like '-*' ){
            Write-Error -Message "Please specify a start time that comes before the end time." -ErrorAction Stop
        }

        $Result = [Math]::Round($TimeDifference.TotalHours, 2)

        if ($null,'25','5','75' -notcontains (([string]$Result).Split('.'))[1]){
            Write-Error -Message "Time Must be calulated in intervals of 15 minutes." -ErrorAction Stop
        }
        else {
            $Result
        }

    }

    end {

    }
}

$Main = [Windows.Forms.Form]@{
    Size = '1024,768'
    Text = 'Faradazed'
}

$Font = New-Object Drawing.Font('GenericSansSerif',24)

#StartTimeLabel
$StartTimeLabel = [Windows.Forms.Label]@{
    Location    = '10,10'
    Text        = 'Start Time (24 Hour)'
    Size        = '325,50'
    BorderStyle = 'FixedSingle'
    Font        = $Font
}

#StartTimeField
$StartTimeTextBox = [Windows.Forms.TextBox]@{
    Location    = '350,10'
    Size        = '100,50'
    Font        = $Font
}

#EndTimeLabel
$EndTimeLabel = [Windows.Forms.Label]@{
    Location    = '10,70'
    Text        = 'End Time (24 Hour)'
    Size        = '325,50'
    BorderStyle = 'FixedSingle'
    Font        = $Font
}

#EndTimeField
$EndTimeTextBox = [Windows.Forms.TextBox]@{
    Location    = '350,70'
    Size        = '100,50'
    Font        = $Font
}

#CalulateButton
$CalculateButton = [Windows.Forms.Button]@{
    Location    = '10,130'
    Text        = 'Calculate'
    Size        = '250,50'
    Font        = $Font
}

#ResultsBox
$ResultsTextBox = [Windows.Forms.TextBox]@{
    Location    = '350,130'
    Size        = '100,50'
    Font        = $Font
}


$Main.Controls.AddRange(@($StartTimeTextBox,$StartTimeLabel,$EndTimeTextBox,$EndTimeLabel,$CalculateButton,$ResultsTextBox))
$Main.ShowDialog()