$cwd = Get-Location
try {
    $agentPath = Join-Path -Path $PSScriptRoot -ChildPath "agents"
    Set-Location $agentPath

    docker build -t my-gocd-agents/base -f dockerfile-base .
    docker build -t my-gocd-agents/dotnet8 -f dockerfile-dotnet8 .
    docker build -t my-gocd-agents/dotnet9 -f dockerfile-dotnet9 .
    docker build -t my-gocd-agents/docker -f dockerfile-docker .
    docker build -t my-gocd-agents/terraform -f dockerfile-terraform .
}
finally {
    Set-Location $cwd
}