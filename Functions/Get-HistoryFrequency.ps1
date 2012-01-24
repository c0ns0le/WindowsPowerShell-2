<#
    Configure global persistent history.
#>

$MaximumHistoryCount = 10Kb
$historyFile = Join-Path (Split-Path $PROFILE) 'history.csv'

function Get-HistoryFrequency
{
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $commands = Get-Command | ?{ $_.CommandType -ne 'Function' }

    Get-History -Count $MaximumHistoryCount `
        | %{        
            $tokens = $_.CommandLine.Split(' ')
            
            foreach($command in $commands) {
                if($command.Name -eq $tokens[0]) { break }
                $command = $null
            }
            
            switch($command.CommandType) {
                'Alias'  { $command.Definition }
                'Cmdlet' { $command.Name }
                default  { ("{0} {1}" -f $tokens[0],$tokens[1]) }
            }
        } `
        | Group-Object `
        | ?{ $_.Count -gt 1 } `
        | Sort-Object Count -Descending `
        | Format-Table Count, @{ Label='Command'; Expression={$_.Name} } -AutoSize
        
    $stopwatch.Stop()
    Write-Debug ("Get-HistoryFrequency {0} ms" -f $stopwatch.ElapsedMilliseconds)
}

Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count $MaximumHistoryCount | Export-Csv $historyFile 
}

if(Test-Path $historyFile) {
    $history = Import-Csv $historyFile 
    "Importing persistent history ({0} of {1} commands)" -f $history.Count,$MaximumHistoryCount
    $history | Add-History
}

Set-Alias hf Get-HistoryFrequency