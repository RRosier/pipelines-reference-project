<#
    .SYNOPSIS
    Set version attribute for code files.

    .DESCRIPTION
    Updates the Directory.Build.props version attributes with the provided version information.

    .PARAMETER version
    The calculated version number in semantic format (major.minor.patch-suffix.build)

    .PARAMETER propsFile
    The Directory.Build.props file to be updated.

    .EXAMPLE
    PS> ./update-build-number.ps1 2.1.2-dev.897 ./source/Directory.Build.props
#>
param (
	[string]$version,
	[string]$propsFile
)

Write-Host "Version: $version"
Write-Host "PropsFile: $propsFile"

$hasMatches = $version -match '(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(?<suffix>-(?<env>[a-z]+)?((\.)?(?<build>\d+))?)?'
if (!$hasMatches) {
	throw "$version not in correct format. Needs to be 'major.minor.patch[-env.build]', where env and build is optional."
}

$versionPrefix = "$($matches.major).$($matches.minor).$($matches.patch)"
$versionSuffix = $matches.suffix -replace '-', ''

if (!(Test-Path $propsFile)) {
	throw "PropsFile '$propsFile' not found."
}

Write-Host "Updating file '$propsFile'..."
$fileContent = [System.Xml.XmlDocument] (Get-Content $propsFile)
$fileContent
$fileContent.Project.PropertyGroup[0].VersionPrefix = $versionPrefix
$fileContent.Project.PropertyGroup[0].VersionSuffix = $versionSuffix
$fileContent.Save($propsFile)

Write-Host "'$propsFile' updated"
Get-Content -path $propsFile