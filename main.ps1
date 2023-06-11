. $PSScriptRoot\FileUtils.ps1
. $PSScriptRoot\Log.ps1

$zipFileName = "123_法语_456.zip"
# TODO 配置文件
$downloadFileDir = "C:\test\home\download"
$extractedFileDir = "C:\test\home\extracted"
$compressedFileDir = "C:\test\home\compressed"



function replaceLang
{
    param(
        [Parameter(Mandatory)]
        [String]$str
    )

    return $str -replace "lang", $lang
}

function extractLang
{
    param(
        [Parameter(Mandatory)]
        [String]$str
    )

    if ($str -match '_(.+?)_')
    {
        $lang_key = $matches[1]
        $lang = $langDict[$lang_key]

        log "语言为: $lang_key -> $lang"

        if ($lang -eq 0)
        {
            log "$lang_key 未配置相应的英文字典"
            exit -1
        }

        return $lang
    }

    log "未能提取语言..."
    exit -1
}

log "开始执行任务..."
$templateDict = readCurrentDirConfFile "template.conf"
log "文件名字典加载完毕"
$langDict = readCurrentDirConfFile "lang.conf"
log "语言字典加载完毕"

$lang = extractLang $zipFileName

function renameExtractedFile()
{
    $files = Get-ChildItem -Path $extractedFileDir\* -Include *.pdf, *.indd
    foreach ($file in $files)
    {
        if ($file -like "*.indd")
        {
            rename $file (replaceLang $templateDict["indd"])
            continue
        }

        if ($file -like "*.pdf")
        {
            if ($file -like "*线上*")
            {
                rename $file (replaceLang $templateDict["online_pdf"])
            }
            else
            {
                rename $file (replaceLang $templateDict["pdf"])
            }
        }
    }
}

#
$zipFile = Join-Path $downloadFileDir $zipFileName
makesureDirExitsAndCleanThenExtract $extractedFileDir $zipFile
renameExtractedFile
#
$newZipFile = Join-Path $compressedFileDir (replaceLang $templateDict["zip"])
makesureDirExitsThenCompress $extractedFileDir $newZipFile





