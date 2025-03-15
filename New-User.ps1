[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $Username,
    [Parameter(Mandatory = $true)]
    [SecureString]
    $Password
)

$zipFile = Join-Path -Path $PSScriptRoot -ChildPath 'bcrypt.net-next.zip'
$dllFile = Join-Path -Path $PSScriptRoot -ChildPath 'BCrypt.Net-Next.dll'
if (-not (Test-Path -Path $dllFile)) {

    Write-Output 'Downloading BCrypt.Net-Next NuGet package...'
    Invoke-WebRequest -Uri 'https://www.nuget.org/api/v2/package/BCrypt.Net-Next' -OutFile $zipFile

    $pathInZip = 'lib/net6.0/BCrypt.Net-Next.dll'

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipFile)
    $entry = $zip.Entries | Where-Object { $_.FullName -eq $pathInZip }
    if ($entry) {
        $entryStream = $entry.Open()
        $fileStream = [System.IO.File]::Create($dllFile)
        $entryStream.CopyTo($fileStream)
        $fileStream.Close()
        $entryStream.Close()
    }
    $zip.Dispose()

    Remove-Item -Path $zipFile -ErrorAction SilentlyContinue
    
    if (Test-Path -Path $dllFile) {
        Write-Host "Extracted BCrypt.Net-Next.dll successfully."
    } else {
        throw "Could not extract BCrypt.Net-Next.dll from the NuGet package."
    }
}
Add-Type -Path $dllFile

$plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
$bcryptHash = [BCrypt.Net.BCrypt]::HashPassword($plainTextPassword, [BCrypt.Net.BCrypt]::GenerateSalt(12))
$htpasswd = "${Username}:${bcryptHash}"

$htpasswd | Add-Content -Path './data/config/passwords'

Write-Output "User added:"
Write-Output $htpasswd