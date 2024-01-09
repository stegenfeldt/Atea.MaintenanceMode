param (
    [string] $FilePath,
    [string] $SolutionFolder
)

# $buildFolder = [string] "$($FilePath.Substring(0,$FilePath.LastIndexOfAny("\")))\"
# $releaseFolder = [string] "$SolutionFolder\Downloads\Windows Client\"
#Set-AuthenticodeSignature -Certificate (dir Cert:\CurrentUser\My\5E1D01C6F02199D1A39D806EB17A961F5C476EE2) -TimestampServer "http://timestamp.digicert.com" -FilePath "$($FilePath)"
