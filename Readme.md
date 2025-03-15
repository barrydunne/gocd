This repository contains custom build agents for GoCD.

# Getting started

Build the agents and run GoCD

```pwsh
./Build-Agents.ps1
./Run-GoCD.ps1
```

## First Run

If this is the first time running GoCD:

1. Open GoCD at http://localhost:8153 and wait for it to start
1. Press `GoCD Server Loaded - Click Here`
1. Ignore creating a New Pipeline and go to the `AGENTS` menu
1. Refresh the page until the agents appear and are shown as enabled
1. Go to `ADMIN > Authorization Configuration > Add`
    * Id: `File`
    * Plugin: `Password File Authentication Plugin`
    * Do **NOT** check `Allow only known users to login` 
    * Password file path: `config/passwords`
1. Press Save and refresh the page until it loads the login page
1. Create at least one username and a strong password using the `New-User.ps1` script.
1. Log in and go to `User > Personal Access Tokens`
1. Give the description `API Access` and click `Generate`. Copy the value for use below.



## Sample Pipeline

1. Create a new Pipeline by running the following with the access token created above
    ```pwsh
    $samplePipeline = Get-Content -Path SamplePipeline.json -Raw
    ./New-Pipeline.ps1 -PipelineJson $samplePipeline -AuthToken <token>
    ```
1. Notify GoCD about a new build version availabile, eg `2025.0309.1959.0001`
    ```pwsh
    ./New-BuildVersion.ps1 -PipelineName 'SamplePipeline' -Version '2025.0309.1959.0001' -AuthToken <token>
    ```
1. Go to the activity page for the new pipeline - http://localhost:8153/go/pipeline/activity/SamplePipeline





