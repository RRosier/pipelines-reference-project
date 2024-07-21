function Write-TimeStamp ($content) {
    Write-Host "[$(Get-Date)] $content" @args
}

$buildConfiguration = 'Debug'
  
$paramsScript = Join-Path $PSScriptRoot "params-local.ps1"
Write-TimeStamp "Read local parameters: $paramsScript" -ForegroundColor green
$params = & "$paramsScript"

$root = (Get-Item $PSScriptRoot).Parent
$sourceRoot = Join-Path $root "source"

Write-TimeStamp "Runnint dotnet build"
$projects = Get-ChildItem -Path $sourceRoot -Filter '*.csproj' -File -Recurse

foreach($p in $projects) {
    dotnet build $p -c $buildConfiguration
}

Write-TimeStamp "Running dotnet test"
$tests = Get-ChildItem -Path $sourceRoot -Filter '*Tests.csproj' -File -Recurse
foreach($p in $tests) {
    dotnet test $p -c $buildConfiguration --no-restore --collect:"XPlat Code Coverage" /p:Exclude="[*Tests]*" # /p:Include="[My.Namespace.*]*" -- we're only interested in code written by us
    # if you use collector.msbuild to collect coverage reports, use following command
    # dotnet test $p -c $buildConfiguration --no-restore /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:Exclude="[*Tests]*"
}