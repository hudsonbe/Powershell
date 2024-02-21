try {
    $computerName = Read-Host -Prompt 'Enter the computer name'
    $credential = Get-Credential

    $SessionArgs = @{
        ComputerName  = $computerName
        Credential    = $credential
        SessionOption = New-CimSessionOption -Protocol Dcom
    }
    $CimSession = New-CimSession @SessionArgs

    $MethodArgs = @{
        ClassName  = 'Win32_Process'
        MethodName = 'Create'
        CimSession = $CimSession
        Arguments  = @{
            CommandLine = "powershell -Command `"Enable-PSRemoting -Force -ErrorAction Stop`""
        }
    }
    $result = Invoke-CimMethod @MethodArgs
    if ($result.ReturnValue -eq 0) {
        Write-Host "PSRemoting enabled successfully on $computerName."
    }
    else {
        Write-Error "Failed to enable PSRemoting on $computerName. Return value: $($result.ReturnValue)"
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    if ($CimSession) {
        Remove-CimSession -CimSession $CimSession
        $CimSession = $null  # Clear the variable to avoid accidental reuse
    }
}


try {
    $ScriptBlock = {
        $processes = Get-Process -Name explorer -ErrorAction SilentlyContinue
        $completedProcesses = 0

        foreach ($process in $processes) {
            if ($process) {
                Write-Host "$($process.Id) is currently running and will be stopped" -ForegroundColor Cyan
                $process | Stop-Process -Force -ErrorAction SilentlyContinue
                $completedProcesses++
            }
            else {
                Write-Host "Explorer process is not running."
            }
        }

        # Start explorer.exe if it was stopped
        if ($completedProcesses -gt 0) {
            Start-Process "explorer.exe"

            # Allow some time for the processes to start
            Start-Sleep -Seconds 2

            $newProcesses = Get-Process -Name explorer -ErrorAction SilentlyContinue
            foreach ($process in $newProcesses) {
                Write-Host "`n Explorer.exe has been restarted. The new $($process.Id) is running" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "Explorer process is not running or could not be found."
        }
    }

    Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $ScriptBlock
}
catch {
    Write-Error "An error occurred during the Explorer restart process: $_"
}