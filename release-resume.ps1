<#
.SYNOPSIS
    Compiles the resume and creates a GitHub release with the PDF attached.
.DESCRIPTION
    Runs compile-resume.ps1, then creates a release for tag vYYYY-MM-DD
    and uploads the built PDF as an asset. Requires GitHub CLI (gh) and auth.
.EXAMPLE
    .\release-resume.ps1
.EXAMPLE
    .\release-resume.ps1 -SkipCompile   # Use existing PDF, only create/update release
#>
Param(
    [string]$MainFile = "main.tex",
    [switch]$SkipCompile
)

$ErrorActionPreference = "Stop"

# Run from repo root
Set-Location $PSScriptRoot

# Ensure gh is on PATH (e.g. after fresh install)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

$today   = Get-Date -Format "yyyy-MM-dd"
$tag     = "v$today"
$pdfName = "Ahmed_Osama_Resume_$today.pdf"

# Step 1: Build PDF unless skipped
if (-not $SkipCompile) {
    Write-Host "Building resume..."
    & "$PSScriptRoot\compile-resume.ps1" -MainFile $MainFile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not (Test-Path $pdfName)) {
    Write-Error "PDF not found: $pdfName. Run without -SkipCompile to build it."
    exit 1
}

# Step 2: Ensure tag exists on remote (create and push if not)
$tagExists = git rev-parse $tag 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating and pushing tag $tag..."
    git tag -a $tag -m "Resume $today"
    git push origin $tag
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Step 3: Create release with PDF, or upload if release already exists
Write-Host "Creating release $tag with PDF..."
gh release create $tag $pdfName --title "Resume $today" --notes "Resume release $today. Built from main.tex."
if ($LASTEXITCODE -ne 0) {
    Write-Host "Release already exists. Uploading PDF as asset..."
    gh release upload $tag $pdfName --clobber
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
Write-Host "Done. Release: https://github.com/ahmed98Osama/ahmed98Osama/releases/tag/$tag"
