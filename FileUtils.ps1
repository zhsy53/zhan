. $PSScriptRoot\Log.ps1

function cleanDir
{
    param(
        [Parameter(Mandatory)]
        [string]$dir
    )

    Remove-Item -Path "$dir\*" -Recurse -Force -ErrorAction SilentlyContinue
}

function deleteFile
{
    param(
        [Parameter(Mandatory)]
        [string]$file
    )
    # LiteralPath:不会对路径中的任何字符进行转义或扩展
    Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}

function readCurrentDirConfFile
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
                $key, $value = $_ -split '\s*=\s*', 2
                $config[$key] = $value
            }
    return $config
}

function makesureDirExitsAndCleanThenExtract
{
    param(
        [Parameter(Mandatory)]
        [String]$dir,

        [Parameter(Mandatory)]
        [String]$zipFile
    )

    New-Item -ItemType Directory -Force -Path $dir

    cleanDir $dir

    log  "解压文件 $zipFile 到 $dir"
    Expand-Archive  -Force $zipFile -DestinationPath $dir
    log   "文件$zipFile解压完成`n"
}

function makesureDirExitsThenCompress
{
    param(
        [Parameter(Mandatory)]
        [String]$dir,

        [Parameter(Mandatory)]
        [String]$zipFile
    )

    deleteFile $zipFile

    New-Item -ItemType Directory -Force -Path (Split-Path $zipFile -Parent)

    log   "压缩 $dir 中的文件至 $zipFile"
    Compress-Archive -Path $dir\* -DestinationPath $zipFile -Force
    log   "$dir 中的文件已压缩完成`n"
}

function rename()
{
    param(
        [Parameter(Mandatory)]
        [String]$file,

        [Parameter(Mandatory)]
        [String]$name
    )

    log "将 $file 重命名为`n$name"
    Rename-Item -Path $file -NewName $name -Force
}