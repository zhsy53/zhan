function CleanDir
{
    param(
        [Parameter(Mandatory)]
        [string]$dir
    )

    Remove-Item -Path $dir\* -Recurse -Force -ErrorAction SilentlyContinue
}

function DeleteFile
{
    param(
        [Parameter(Mandatory)]
        [string]$file
    )
    # LiteralPath:不会对路径中的任何字符进行转义或扩展
    Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}

function ReadCurrentDirConfFile
{
    param(
        [Parameter(Mandatory)]
        [String]$currentDirFilename
    )

    # 空的hash表
    $config = @{ }


    # $_管道中当前正在处理的对象
    Get-Content (Join-Path $PSScriptRoot $currentDirFilename) |
            Where-Object { $_ -notmatch "^\s*#" } |
            ForEach-Object { $_.split("#")[0].TrimEnd() } |
            ForEach-Object {
                $key, $value = $_ -split "\s*=\s*", 2
                $config[$key] = $value
            }

    return $config
}

function MakesureDirExitsAndCleanThenExtract
{
    param(
        [Parameter(Mandatory)]
        [String]$dir,

        [Parameter(Mandatory)]
        [String]$zipFile
    )

    New-Item -ItemType Directory -Force -Path $dir

    CleanDir $dir

    Write-Output "expand $zipFile to $dir"
    Expand-Archive $zipFile -DestinationPath $dir -Force
    Write-Output "$zipFile expand finished"
}

function MakesureDirExitsThenCompress
{
    param(
        [Parameter(Mandatory)]
        [String]$dir,

        [Parameter(Mandatory)]
        [String]$zipFile
    )

    New-Item -ItemType Directory -Force -Path (Split-Path $zipFile -Parent)

    DeleteFile $zipFile

    Write-Output "compress $dir files to $zipFile"
    Compress-Archive -Path $dir\* -DestinationPath $zipFile -Force
    Write-Output "$dir files compress finished"
}

function RenameFile
{
    param(
        [Parameter(Mandatory)]
        [String]$file,
        [Parameter(Mandatory)]
        [String]$name
    )
    Write-Output $file


    Write-Output "rename $( Split-Path $file -Leaf ) -> $name"
    Rename-Item -Path $file -NewName $name -Force
}