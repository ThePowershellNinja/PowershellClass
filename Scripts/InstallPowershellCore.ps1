Param (

    #$ComputerName = Get-ADComputer -Filter * -Server Lab.local -Properties OperatingSystem | Where {$_.OperatingSystem -notlike "*Linux*"} | Select -Expand DNSHostName
    [string[]]$ComputerName = 'lab-ms01.lab.local',

    [PSCredential]$Credential = (Get-Credential -UserName lab\mbattin -Message "Enter Password")
)

Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {

    $PowershellInstallerPath = 'C:\Temp\PowerShell-7.0.2-win-x64.msi'

    # Download Powershell Core
    Write-Progress -Activity "Setting up Powershel Core" -Status "Downloading Powershell core on: $env:ComputerName"
    New-Item -Path C:\Temp -Force -ErrorAction SilentlyContinue | Out-Null
    Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/PowerShell-7.0.2-win-x64.msi' -OutFile $PowershellInstallerPath

    # Install Powershell Core
    Write-Progress -Activity "Setting up Powershel Core" -Status "Installing Powershell core on: $env:ComputerName"
    try {
        Start-Process -FilePath msiexec -ArgumentList "/i $PowershellInstallerPath /qn /norestart" -Wait -ErrorAction Stop
        $InstalledPSCore = $True
    }
    catch {
        $InstalledPSCore = $False
        Write-Error "Could not install Powershell Core on $env:ComputerName"
    }

    # Install SSH Client and Server
    Write-Progress -Activity "Setting up Powershel Core" -Status "Installing SSH Server and Client on: $env:ComputerName"
    try {
        Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0" -ErrorAction Stop | Out-Null
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" -ErrorAction Stop | Out-Null
        $InstalledSSH = $True
    }
    catch {
        $InstalledSSH = $False
        Write-Error "Could not install SSH on $env:ComputerName"
    }

    [PSCustomObject]@{
        ComputerName            = $env:ComputerName
        InstalledPowershellCore = $InstalledPSCore
        InstalledSSH            = $InstalledSSH
    }
    Write-Progress -Activity "Setting up Powershel Core" -Completed
} -HideComputerName | Select * -ExcludeProperty RunspaceID