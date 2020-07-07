function Calculate-Time {

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