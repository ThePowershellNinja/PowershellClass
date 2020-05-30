[CmdletBinding()]

Param (
    
    [string]$Name = 'PowershellClass',

    [string]$ServerAddress = 'justtoclayrify.net',

    [ValidateSet('PPTP','L2TP','SSTP','IKEv2','Automatic')]
    [string]$Protocol = 'PPTP',

    [string]$DNSServer = '192.168.7.5',

    [string]$DNSSuffix = 'lab.local'
)

begin {

    $PBKPath = "$env:APPDATA\Microsoft\Network\Connections\Pbk\rasphone.pbk"
}

process {

    try {
        Add-VpnConnection -RememberCredential -Name $Name -ServerAddress $ServerAddress -TunnelType $Protocol -SplitTunneling -ErrorAction Stop
        $PBKFile = Get-Content $PBKPath -Raw
        $PBKFile += "[removeme]"
        function Set-ConfigProperty ([string]$ItemName, [string]$Value) {
            $regex = "(?<=\[$Name\].*?)(?=.*?(\[.*?\])|$)($ItemName=.*?\r\n)"
            [regex]::Replace($PBKFile,$regex,"$ItemName=$Value`r`n",[System.Text.RegularExpressions.RegexOptions]"SingleLine")
        }
        
    
        $PBKFile = Set-ConfigProperty -ItemName 'ExcludedProtocols' -Value '11'
        $PBKFile = Set-ConfigProperty -ItemName 'IpDnsAddress' -Value $DNSServer
        $PBKFile = Set-ConfigProperty -ItemName 'IpDnsSuffix' -Value $DNSSuffix
        $PBKFile = Set-ConfigProperty -ItemName 'AutoTiggerCapable' -Value '1'
        $PBKFile = Set-ConfigProperty -ItemName 'IpNameAssign' -Value '2'

        $PBKFile = $PBKFile -replace '\[removeme\]',''
        $PBKFile | Out-File -FilePath $PBKPath -Force -Encoding ASCII -NoNewline
    }
    catch {
        Write-Error $_ -ErrorAction Stop
    }
}

end {

}