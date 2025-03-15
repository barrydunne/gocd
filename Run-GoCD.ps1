$data = Join-Path -Path $PSScriptRoot -ChildPath 'data'

$containerId = docker ps -q -f name=GoCD
if (-not $containerId) {
    Write-Host 'Starting GoCD...'
    docker run -d `
        --name GoCD `
        --restart unless-stopped `
        -p 8153:8153 `
        -v ${data}:/godata `
        gocd/gocd-server:v25.1.0
}

$cruiseConfig = Join-Path -Path $PSScriptRoot -ChildPath 'data' -AdditionalChildPath 'config', 'cruise-config.xml'
$attempt = 0
$agentKey = $null
while (-not $agentKey -and $attempt -lt 20) {
    if (Test-Path $cruiseConfig) {
        $result = Select-Xml -Path $cruiseConfig -XPath '//server/@agentAutoRegisterKey' -ErrorAction SilentlyContinue
        if ($result) {
            $agentKey = $result.Node.Value
            break
        }
    }
    if (-not $agentKey) {
        $attempt++
        Write-Host "Agent Auto Register Key not found. Retrying in 5 seconds. Attempt $attempt of 20."
        Start-Sleep -Seconds 5
    }
}
if (-not $agentKey) {
    Write-Host "Agent Auto Register Key not found after $attempt attempts."
}

$containerId = docker ps -q -f name=GoCD-agent-dotnet9
if (-not $containerId) {
    Write-Host 'Starting GoCD .Net9 Agent...'
    docker run -d `
        --name GoCD-agent-dotnet9 `
        --restart unless-stopped `
        -e GO_SERVER_URL=http://host.docker.internal:8153/go `
        -e AGENT_AUTO_REGISTER_KEY=$agentKey `
        -e AGENT_AUTO_REGISTER_HOSTNAME=dotnet9 `
        -e AGENT_AUTO_REGISTER_RESOURCES=any,net,net9,aws,pwsh,pwsh7 `
        -e DOTNET_CLI_TELEMETRY_OPTOUT=1 `
        my-gocd-agents/dotnet9
}

$containerId = docker ps -q -f name=GoCD-agent-docker
if (-not $containerId) {
    Write-Host 'Starting GoCD Docker Agent...'
    docker run -d `
        --name GoCD-agent-docker `
        --restart unless-stopped `
        -v //var/run/docker.sock:/var/run/docker.sock `
        -e LOCALSTACK_AUTH_TOKEN=$env:LOCALSTACK_AUTH_TOKEN `
        -e GO_SERVER_URL=http://host.docker.internal:8153/go `
        -e AGENT_AUTO_REGISTER_KEY=$agentKey `
        -e AGENT_AUTO_REGISTER_HOSTNAME=docker `
        -e AGENT_AUTO_REGISTER_RESOURCES=any,docker,aws,pwsh,pwsh7 `
        my-gocd-agents/docker
}

$containerId = docker ps -q -f name=GoCD-agent-terraform
if (-not $containerId) {
    Write-Host 'Starting GoCD Terraform Agent...'
    docker run -d `
        --name GoCD-agent-terraform `
        --restart unless-stopped `
        -e GO_SERVER_URL=http://host.docker.internal:8153/go `
        -e AGENT_AUTO_REGISTER_KEY=$agentKey `
        -e AGENT_AUTO_REGISTER_HOSTNAME=terraform `
        -e AGENT_AUTO_REGISTER_RESOURCES=any,terraform,aws,pwsh,pwsh7 `
        my-gocd-agents/terraform
}
