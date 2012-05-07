param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty]
    [string]$input
)

$token = 'OmnyxScannerLogger'

$item = (Get-Item $input)
$output = $item.Directory + $item.BaseName + 'trimmed' + $item.Extension

(Get-Content $input) `
    | ?{ -not $_.Contains($token) } `
    | Set-Content $output