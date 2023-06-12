Param(
    [Parameter(Mandatory)]
    [String]$zipFile # C:\Users\zsy\Desktop\随便1_法语_随便2.zip
)

#$PSDefaultParameterValues['*:Encoding'] = 'UTF8'

. $PSScriptRoot\FileUtils.ps1
. $PSScriptRoot\LangUtils.ps1

Write-Output "开始 process for $zipFile ..."
$templateDict = ReadCurrentDirConfFile "conf\template.conf"
Write-Output "filename mapping dict load finished, entry count: $( $templateDict.Count )"
$langDict = ReadCurrentDirConfFile "conf\lang.conf"
Write-Output "lang mapping dict load finished, entry count: $( $langDict.Count )"
$workDict = ReadCurrentDirConfFile "conf\work.conf"

$extractedFileDir = $workDict["extractedFileDir"]
$compressedFileDir = $workDict["compressedFileDir"]

$tmpDir = [System.IO.Path]::GetFileNameWithoutExtension($zipFile)
$extractedFileDir += "\$tmpDir"
$compressedFileDir += "\$tmpDir"
Write-Debug "extractedFileDir: $extractedFileDir"
Write-Debug "compressedFileDir: $compressedFileDir"

$lang = ExtractLangAndConvertToEN $zipFile $langDict
Write-Output "extracted lang: $lang"

MakesureDirExitsAndCleanThenExtract $extractedFileDir $zipFile

$files = Get-ChildItem -Path $extractedFileDir\* -Include *.pdf, *.indd

foreach ($file in $files)
{
    $newFilename = ""
    if ($file.Name -like "*.indd")
    {
        $newFilename = $templateDict["indd"]
    }
    elseif( $file.Name -like "*.pdf" )
    {
        if ($file.Name -like "*线上*")
        {
            $newFilename = $templateDict["online_pdf"]
        }
        else
        {
            $newFilename = $templateDict["pdf"]
        }
    }

    if (-not($newFilename -eq ""))
    {
        RenameFile $file (ReplaceLang $newFilename $lang)
    }

}

$newZipFile = Join-Path $compressedFileDir (ReplaceLang $templateDict["zip"] $lang)
MakesureDirExitsThenCompress $extractedFileDir $newZipFile

$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") > $null
