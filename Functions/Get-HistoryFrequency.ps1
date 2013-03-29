<#
    PowerShell throws out the command history when you exit a session. This 
    script will persist 10 Kb of history in a CSV file in your profile. It will
    be reloaded into history when a new session is started.
#>

$MaximumHistoryCount = 10Kb
$HistoryFile = Join-Path (Split-Path $PROFILE) 'history.csv'
$script:Commands = Get-Command | Get-Unique | % -begin { $x = @{} } -process { if(-not($x.ContainsKey($_.Name))) { $x.Add($_.Name, $_) } } -end { $x }

function Get-HistoryFrequency
{
    Get-History -Count $MaximumHistoryCount `
        | %{ Get-CommandDefinition $_ } `
        | Group-Object `
        | ?{ $_.Count -gt 10 } `
        | Sort-Object Count -Descending `
        | Format-Table Count, @{ Label='Command'; Expression={$_.Name} } -AutoSize
}

function Get-CommandDefinition($item) {
    $tokens = $item.CommandLine.Split(' ')
    
    $name = $tokens[0]
    $arg1 = $tokens[1]
    
    $command = $null
    if($script:Commands.ContainsKey($name)) {
        $command = $script:Commands[$name]
    }
    
    switch($command.CommandType) {
        'Alias'  { $command.Definition }
        'Cmdlet' { $command.Name }
        default  { ("{0} {1}" -f $name,$arg1) }
    }    
}

Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count $MaximumHistoryCount | Export-Csv $HistoryFile 
}

if(Test-Path $HistoryFile) {
    $history = Import-Csv $HistoryFile 
    "Importing persistent history ({0} of {1} commands)" -f $history.Count,$MaximumHistoryCount | Write-Debug
    $history | Add-History
}

Set-Alias hf Get-HistoryFrequency