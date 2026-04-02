function g {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    git @Args
}

function studio {
    param([string]$Path = '.')

    & 'C:\Program Files\Android\Android Studio\bin\studio64.exe' $Path
}