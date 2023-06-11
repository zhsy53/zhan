function log
{
    param(
        [Parameter(Mandatory)]
        [string]$msg
    )
    Write-Host $msg -ForegroundColor DarkMagenta -BackgroundColor White
}