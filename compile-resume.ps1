Param(
    [string]$MainFile = "main.tex"
)

if (-not (Test-Path $MainFile)) {
    Write-Error "LaTeX file '$MainFile' not found."
    exit 1
}

# Use today's date in the output PDF name: Ahmed_Osama_Resume_YYYY-MM-DD.pdf
$today   = Get-Date -Format "yyyy-MM-dd"
$jobname = "Ahmed_Osama_Resume_$today"

Write-Host "Compiling '$MainFile' to '$jobname.pdf'..."

$pdflatexArgs = @(
    '-interaction=nonstopmode',
    '-halt-on-error',
    "-jobname=$jobname",
    $MainFile
)
& pdflatex @pdflatexArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "pdflatex failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

# Copy to fixed name so the latest PDF can be committed to the repo
Copy-Item -Path "$jobname.pdf" -Destination "Ahmed_Osama_Resume.pdf" -Force
Write-Host "Done. Output: $jobname.pdf (latest copy: Ahmed_Osama_Resume.pdf)"

