# Helper PowerShell script: stage and push only notebooks, code and docs
# Usage: Open PowerShell in repo root and run: ./scripts/push_notebooks.ps1 -Message "Your commit message" -Branch "main"
param(
    [string]$Message = "Update notebooks",
    [string]$Branch = "main",
    [switch]$DryRun
)

Write-Host "Finding files to add: .ipynb, .py, .md, .yml, .toml"
$files = Get-ChildItem -Path . -Recurse -Include *.ipynb,*.py,*.md,*.yml,*.toml -File | Select-Object -ExpandProperty FullName

if ($files.Count -eq 0) {
    Write-Host "No matching files found to add."; exit 1
}

Write-Host "Files that will be staged: $($files.Count) files"
if ($DryRun) {
    $files | ForEach-Object { Write-Host "  $_" }
    Write-Host "Dry run: nothing staged."; exit 0
}

# Stage each file safely (use -- to avoid pathspec issues)
foreach ($f in $files) {
    git add -- "$f"
}

# Show status
git status --porcelain

# Commit
git commit -m $Message

# Push (will fail if no remote configured)
Write-Host "Pushing to branch: $Branch"
git push origin $Branch
