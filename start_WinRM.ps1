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

