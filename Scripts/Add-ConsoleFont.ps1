param(
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $FontName
)

# This registry key lists the fonts available in the console. The fonts are keyed
# with incrementing zeroes ('0'). We'll get the font keys and all of the font names 
# for invariant checks.
#
#     http://support.microsoft.com/default.aspx?scid=KB;EN-US;Q247815
#
$consoleRegkey = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont'
$fontKeys = (Get-Item $consoleRegkey).GetValueNames() | ?{ $_.StartsWith('0') }

$fonts = @()
foreach($key in $fontKeys) {
    $fonts += (Get-ItemProperty $consoleRegkey -Name $key).$key
}

# Check to see if the font is already installed for this console.
#
if($fonts -contains $FontName) {
    Write-Debug "Font already installed: $FontName"
    return
}

# Check to see if the font is installed on the system for use in the console.
#
$fontRegkey = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$fontNames = (Get-Item $fontRegkey).GetValueNames()

if($fontNames -notcontains $FontName) {
    Write-Error "The font is not installed: $FontName"
    return
}

# Get the next font key and add the property.
#
$newFontKey = $null
0..$fontKeys.Length | %{ $newFontKey += '0' }
New-ItemProperty $consoleRegkey -Name $newFontKey -Value $FontName