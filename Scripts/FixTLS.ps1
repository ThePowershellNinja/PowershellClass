Push-Location hklm:
$RootPaths = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v?.*","HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v?.*"
New-ItemProperty -Path $RootPaths -PropertyType 'dword' -Name 'SchUseStrongCrypto' -Value 1 -Force
Pop-Location