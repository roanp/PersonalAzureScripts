#region 64-bit elevation
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-Host "c'mon Microsoft... Really? Moving to 64bit"
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -executionPolicy Bypass -NoProfile $myInvocation.Line
    }
    else {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -executionPolicy Bypass -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
    exit $lastexitcode
}
#endregion


#region Config
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = "RPAES"
$appName = "Misc"
$LogPath = "$Env:ProgramData\$client\logs"
$logFile = "$logPath\$appName.log"
$InstallFile = "$logPath\$appName-installed.log"
$cachePath = "$Env:ProgramData\$client\cache"

#endregion
#region environment configure
if (!(Test-Path -Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | out-null
}

if (!(Test-Path -Path $cachePath )) {
    New-Item -Path $cachePath -ItemType Directory -Force | out-null
}

$cachePath 
#endregion
Start-Transcript -Path $logFile -Force

try {
    # Install Chocolatey if it isn't already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

}
catch {
    <#Do this if a terminating exception happens#>
    $errorMsg = $_.Exception.Message
}
#region Main Application
try {
    Write-Host "Installing apps with Chocolatey installer.."
  ### Run Chocolatey installers for commodity software

choco install 7zip -y
choco install adobereader -y 
choco install azure-data-studio -y
choco install filezilla -y
choco install firefox -y
choco install git -y
choco install sql-server-management-studio -y
choco install sqlserver-odbcdriver -y
choco install notepadplusplus -y
choco install dbeaver -y
choco install sublimetext4 -y
choco install vscode -y
choco install powershell-core -y


}
catch {
    $errorMsg = $_.Exception.Message
}
finally {
    if ($errorMsg) {
        Write-Warning $errorMsg
        Stop-Transcript
        Throw $errorMsg
    }
    else {
        Write-Host "Installation completed successfully.."
        New-Item -Path $InstallFile  -Force | out-null

        Stop-Transcript
    }
}
#endregion



