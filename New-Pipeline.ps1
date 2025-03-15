param (
    [Parameter(Mandatory=$true)]
    [string]$PipelineJson,
    [Parameter(Mandatory=$true)]
    [string]$AuthToken
)

$server = 'http://localhost:8153'
$baseUrl = "$server/go/api/admin"
$headers = @{ 'Accept' = 'application/vnd.go.cd+json'; 'Content-Type' = 'application/json'; 'Authorization' = "Bearer $AuthToken" }
$definition = $PipelineJson | ConvertFrom-Json
$pipelineGroup = $definition.group
$pipelineName = $definition.pipeline.name

function Get-PipelineGroup {
    $response = Invoke-RestMethod -Uri "$baseUrl/pipeline_groups" -Headers $headers -Method Get
    $groups = $response._embedded.groups
    return $groups | Where-Object { $_.name -eq $pipelineGroup }
}

function New-PipelineGroup {
    Write-Output "Creating pipeline group: $pipelineGroup"
    $body = @{ "name" = $pipelineGroup } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$baseUrl/pipeline_groups" -Headers $headers -Method Post -Body $body
    Write-Output $response._links.self.href
}

function Get-Pipeline {
    try {
        Invoke-RestMethod -Uri "$baseUrl/pipelines/$pipelineName" -Headers $headers -Method Get
        return $true
    } catch {
        return $false
    }
}

function New-Pipeline {
    Write-Output "Creating pipeline: $pipelineName"
    $headers['X-GoCD-Confirm'] = 'true'
    $response = Invoke-RestMethod -Uri "$baseUrl/pipelines" -Headers $headers -Method Post -Body $PipelineJson
    Write-Output $response._links.self.href
}

if (-not (Get-PipelineGroup)) {
    New-PipelineGroup
    Write-Output "Created pipeline group: $pipelineGroup"
} else {
    Write-Output "Pipeline group already exists: $pipelineGroup"
}

if (-not (Get-Pipeline)) {
    New-Pipeline
    Write-Output "Created pipeline: $pipelineName"
} else {
    Write-Output "Pipeline already exists: $pipelineName"
}