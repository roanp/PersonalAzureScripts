$Servers = @(
    "SERVER01"
    , "SERVER02"
    #Add as many servers as you want just make sure there a "," before the server name
)
$Path = "C:\Program Files (x86)\Folder\*"
Foreach ($Server in $Servers) {

    $Destination = "\\$Server\C$\Program Files (x86)\Folder\"

    Write-host "Copying files from $Path to $Destination"

    Copy-Item -Path $Path -Destination $Destination -force -Recurse -Verbose

    Write-host "Done!!!! \0/"


}