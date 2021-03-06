Add-Type -AssemblyName System.Drawing, System.Windows.Forms

function Get-BillingHours {

    [CmdletBinding()]

    Param (

        #[ValidatePattern('^[0-2][0-9][0-5][0-9]$')]
        [string]$StartTime,

        #[ValidatePattern('^[0-2][0-9][0-5][0-9]$')]
        [string]$EndTime
    )

    begin {

    }

    process {

        if ($EndTime -eq '2400') {
            $EndTime = '2359'
        }

        try {
            $ConvertedStartTime = [DateTime]::ParseExact($StartTime, 'HHmm', $null)
            if ($EndTime -eq '2359') {
                $ConvertedStartTime = $ConvertedStartTime - (New-TimeSpan -Minutes 1)
            }
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

function Size ($Width,$Height){New-Object Drawing.Size($Width,$Height)}
function Point ($X,$Y){New-Object Drawing.Point($X,$Y)}

$Main = [Windows.Forms.Form]@{
    ClientSize      = Size 460 250
    Text            = 'Faradazed'
    FormBorderStyle = 'Fixed3d'
    Icon            = "$PSScriptRoot\faradazed.ico"
}

$Font = New-Object Drawing.Font('GenericSansSerif',24)

#StartTimeLabel
$StartTimeLabel = [Windows.Forms.Label]@{
    Location    = Point 10 10
    Text        = 'Start Time (24 Hour)'
    Size        = Size 325 50
    BorderStyle = 'FixedSingle'
    Font        = $Font
}

#StartTimeField
$StartTimeTextBox = [Windows.Forms.TextBox]@{
    Location    = Point 350 10
    Size        = Size 100 50
    Font        = $Font
}

#EndTimeLabel
$EndTimeLabel = [Windows.Forms.Label]@{
    Location    = Point 10 70
    Text        = 'End Time (24 Hour)'
    Size        = Size 325 50
    BorderStyle = 'FixedSingle'
    Font        = $Font
}

#EndTimeField
$EndTimeTextBox = [Windows.Forms.TextBox]@{
    Location    = Point 350 70
    Size        = Size 100 50
    Font        = $Font
}

#CalulateButton
$CalculateButton = [Windows.Forms.Button]@{
    Location    = Point 10 130
    Text        = 'Calculate'
    Size        = Size 250 50
    Font        = $Font
}

#ResultsBox
$ResultsTextBox = [Windows.Forms.TextBox]@{
    Location    = Point 350 130
    Size        = Size 100 50
    Font        = $Font
    ReadOnly    = $true
}

$StatusField = [Windows.Forms.Label]@{
    Location  = Point 10 190
    Size      = Size ($Main.ClientSize.Width - 20) 50
    Font      = New-Object Drawing.Font('GenericSansSerif',12)
    Text      = ''
    BackColor = [System.Drawing.color]::Black
    ForeColor = [System.Drawing.Color]::Red
}

$CalculateButton_Click = {
    try {
        $StatusField.Text = $null
        $ResultsTextBox.Text = Get-BillingHours -StartTime $StartTimeTextBox.Text -EndTime $EndTimeTextBox.Text -ErrorAction Stop
    }
    catch {
        $StatusField.Text = $_
    }
}
$CalculateButton.Add_Click($CalculateButton_Click)
$TextChanged = {
    if ($this.Text -match '[^0-9]') {
        $cursorPos = $this.SelectionStart
        $this.Text = $this.Text -replace '[^0-9]',''
        # move the cursor to the end of the text:
        # $this.SelectionStart = $this.Text.Length

        # or leave the cursor where it was before the replace
        $this.SelectionStart = $cursorPos - 1
        $this.SelectionLength = 0
    }

    if ($this.Text.Length -gt 4){
        $cursorPos = $this.SelectionStart
        $this.Text = $this.Text[0..3]
        $this.SelectionStart = $cursorPos - 1
        $this.SelectionLength = 0
    }
}

$StartTimeTextBox.Add_TextChanged($TextChanged)
$EndTimeTextBox.Add_TextChanged($TextChanged)


$Main.Controls.AddRange(@($StartTimeTextBox,$StartTimeLabel,$EndTimeTextBox,$EndTimeLabel,$CalculateButton,$ResultsTextBox,$StatusField))
$Main.ShowDialog()