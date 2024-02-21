#This PowerShell script enables IT administrators to start winRm on a target machine
#using CIM sessions instead of PSRemoting. 
#This approach can be beneficial in environments where PSRemoting is not enabled by default 
#or for quick troubleshooting on remote computers.

try {
    $SessionArgs = @{
        ComputerName  = 'rsampsonw10e'
        Credential    = Get-Credential
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
        Write-Host "PSRemoting enabled successfully on rsampsonw10e."
    }
    else {
        Write-Error "Failed to enable PSRemoting on rsampsonw10e. Return value: $($result.ReturnValue)"
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    if ($CimSession) {
        Remove-CimSession -CimSession $CimSession
    }
}

