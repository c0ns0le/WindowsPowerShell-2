<# 
    .SYNOPSIS
    Report the projects that have post build steps.
    
    .DESCRIPTION
    Wondering why your projects fail to build from the command line? 
    From TeamCity? or as part of an AutoTest.NET watched directory? 
    Wonder no more! Run this function to report all the projects that 
    have gnarly post-build steps and see what those steps are.
    
    .PARAMETER path
    The root path to the Visual Studio solution where you want to 
    start looking for projects.
    
    .EXAMPLE
    Get-PostBuildSteps
    
    Get the post build steps of any C# project file (.csproj).
    
    .EXAMPLE
    Scripts:\Get-PostBuildSteps.ps1 > post-build-steps.txt
    
    Export the post-build steps to a file.
#>
param([string]$path = ".")

Get-ChildItem $path -Recurse -Include *.csproj | %{ 
    $xml = [xml] (Get-Content $_)
    $postbuild = $xml.Project.PropertyGroup | ?{ $_.PostBuildEvent -ne $null }
        
    if($postbuild -ne $null -and $postbuild.InnerText -ne '')
    {
        '=================================================='
        $_.BaseName
        '--------------------------------------------------'
        $postbuild.InnerText
        '=================================================='
        ''
    }
}