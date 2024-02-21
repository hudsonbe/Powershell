#mport the necessary PowerShell modules:
Import-Module -Name Microsoft.PowerShell.Management
Import-Module -Name Microsoft.PowerShell.Utility

#Retrieve the Application event log entries
$eventLogEntries = Get-EventLog -LogName Application -EntryType Error -Newest 1000

#Analyze the log entries
# Group log entries by event source
$groupedEntries = $eventLogEntries | Group-Object -Property Source #|Format-Table -Auto

#Percentage of error occurrences 
$totalCount = $eventLogEntries.Count

#Most common error messages
$commonErrors = $eventLogEntries | Group-Object -Property Message | Sort-Object -Property Count -Descending | Select-Object -First 5


function logCount{
# Iterate over each group
foreach ($group in $groupedEntries) {
    $source = $group.Name
    $count = $group.Count
    $percentage = ($count / $totalCount) * 100

    # Create a custom object for formatting
    $output = [PSCustomObject]@{
        "Event Source" = $source
        "Event Count" = $count
        "Percentage" = "$percentage%"
    }

    # Format and display the output
    $output | Format-Table -AutoSize
    Write-Host "--------------------------`n"
}
} #end function logcCount


function commonErrors{
foreach ($err in $commonErrors) {
    $message = $err.Name
    $errorCount = $err.Count

    # Print the error message and count
    Write-Host "Count: $errorCount"
    Write-Host "Error Message: $message"
    Write-Host "`n--------------------------"
}
}#end function commonErrors

function errorOccurrences{
$groupedEntries | Sort-Object -Property Name | ForEach-Object {
    $source = $_.Name
    $occurrences = $_.Group | Group-Object -Property { $_.TimeGenerated.Date } | Sort-Object -Property Name

    Write-Host "Event Source: $source"
    Write-Host "Error Occurrences Over Time:"
    $occurrences | Format-Table -Property @{ Name = "Date"; Expression = { $_.Name } }, Count
    Write-Host "--------------------------"
}
}#end function commonErrors