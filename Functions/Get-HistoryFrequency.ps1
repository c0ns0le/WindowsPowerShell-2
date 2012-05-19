<#
    Configure global persistent history.
#>

$MaximumHistoryCount = 10Kb
$HistoryFile = Join-Path (Split-Path $PROFILE) 'history.csv'

function Get-HistoryFrequency
{
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
}

Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count $MaximumHistoryCount | Export-Csv $HistoryFile 
}

if(Test-Path $HistoryFile) {
    $history = Import-Csv $HistoryFile 
    "Importing persistent history ({0} of {1} commands)" -f $history.Count,$MaximumHistoryCount
    $history | Add-History
}

Set-Alias hf Get-HistoryFrequency