# deploy.ps1

# Example: Move files to another folder on the Windows server
Move-Item -Path "path/to/your/files/*" -Destination "\\YourServer\C$\Path\To\Destination" -Force
# Load IIS module:
Import-Module WebAdministration

# Get AppPool Name
$appPoolName = 'git-actions-poc'
# Get the number of retries
$retries = 3
# Get the number of attempts
$delay = 10

# Check if exists
if(Test-Path IIS:\AppPools\$appPoolName) {

    # Stop App Pool if not already stopped
    if ((Get-WebAppPoolState $appPoolName).Value -ne "Stopped") {
        Write-Output "Stopping IIS app pool $appPoolName"
        Stop-WebAppPool $appPoolName

        $state = (Get-WebAppPoolState $appPoolName).Value
        $counter = 1

        # Wait for the app pool to the "Stopped" before proceeding
        do{
            $state = (Get-WebAppPoolState $appPoolName).Value
            Write-Output "$counter/$retries Waiting for IIS app pool $appPoolName to shut down completely. Current status: $state"
            $counter++
            Start-Sleep -Milliseconds $delay
        }
        while($state -ne "Stopped" -and $counter -le $retries)

        # Throw an error if the app pool is not stopped
        if($counter -gt $retries) {
            throw "Could not shut down IIS app pool $appPoolName. `nTry to increase the number of retries ($retries) or delay between attempts ($delay milliseconds)." }
    }
    else {
        Write-Output "$appPoolName already Stopped"
    }
}
else {
    Write-Output "IIS app pool $appPoolName doesn't exist"
}

Write-Output "Starting IIS app pool $appPoolName"
Start-WebAppPool $appPoolName


