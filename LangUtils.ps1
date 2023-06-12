function ExtractLangAndConvertToEN
{
    param(
        [Parameter(Mandatory)]
        [String]$file,

        [Parameter(Mandatory)]
        [hashtable]$langDict
    )

    $regex = "(?<=_)\w+语(?=_)"
    if ($file -match $regex)
    {
        $lang_key = $matches[0]

        $lang = $langDict[$lang_key]

        if ($lang -eq 0)
        {
            Write-Error "lang $lang_key not found mapping in dict config"
            exit -1
        }

        return $lang
    }

    Write-Error "can not extract lang from $file"
    exit -1
}

function ReplaceLang
{
    param(
        [Parameter(Mandatory)]
        [String]$str,
        [Parameter(Mandatory)]
        [String]$lang
    )

    return $str -replace "lang", $lang
}