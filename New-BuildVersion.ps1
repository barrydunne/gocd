param (
    [Parameter(Mandatory=$true)]
    [string]$PipelineName,
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [Parameter(Mandatory=$true)]
    [string]$AuthToken
)

$server = 'http://localhost.localstack.cloud:8153'
$pipelineUrl = "$server/go/api/pipelines/$PipelineName/schedule"
$headers = @{ 'Accept' = 'application/vnd.go.cd+json'; 'Content-Type' = 'application/json'; 'Authorization' = "Bearer $AuthToken" }

$json = @"
{
  "environment_variables": [
    { "name": "VERSION", "value": "$Version" },
    { "name": "BUILD_ARTIFACT", "value": "MyBinary.zip" },
    { "name": "RUN_DISPLAY_URL", "value": "http://localhost/mybuild/1" },
    { "name": "GIT_BRANCH", "value": "master" },
    { "name": "GIT_COMMIT", "value": "d841a32bccd005be4c2888ec0f3452705ccca6b4" }
  ]
}
"@
Write-Output "Creating pipeline version at: $pipelineUrl"
Write-Output $json
$response = Invoke-RestMethod -Uri $pipelineUrl -Headers $headers -Method Post -Body $json
Write-Output $response.message
