# COMMON PATHS
$ErrorActionPreference = "Stop"
$buildFolder = (Get-Item -Path "./" -Verbose).FullName
$slnFolder = Join-Path $buildFolder "../"
$outputFolder = "F:\CODE_AITS\lms\SourceCode\aspnet-core\build\outputs\host"
$webHostFolder = Join-Path $slnFolder "src/AITS.ERP.Web.Host"
$ngFolder = Join-Path $buildFolder "../../angular"
$webReportFolder = Join-Path $slnFolder "src/AITS.ERP.Web.ViewReport"
$webUrl = "http://mis.ngvgroup.vn"
$webAPIUrl = "http://apimis.ngvgroup.vn"
$newCnn = "SERVER=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=27.71.224.55)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=orcl)));uid=ETL_PORTAL;pwd=ETL_PORTAL;direct=true;"
## CLEAR ######################################################################

Remove-Item $outputFolder -Force -Recurse -ErrorAction Ignore
New-Item -Path $outputFolder -ItemType Directory

## RESTORE NUGET PACKAGES #####################################################

Set-Location $slnFolder
dotnet restore

## PUBLISH WEB HOST PROJECT ###################################################

Set-Location $webHostFolder
dotnet publish --output (Join-Path $outputFolder "Host")

# Change Public configuration
$hostConfigPath = Join-Path $outputFolder "Host/appsettings.production.json"
$oldCnn = "SERVER=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=49161))(CONNECT_DATA=(SERVICE_NAME=xe)));uid=mis;pwd=mis;direct=true;"

(Get-Content $hostConfigPath).Replace($oldCnn, $newCnn) | Set-Content $hostConfigPath
(Get-Content $hostConfigPath).Replace("http://localhost:9901", $webAPIUrl) | Set-Content $hostConfigPath
(Get-Content $hostConfigPath).Replace("http://localhost:4200", $webUrl) | Set-Content $hostConfigPath

$hostConfigPath = Join-Path $outputFolder "Host/web.config"
(Get-Content $hostConfigPath).Replace("processPath=`"dotnet`"", "processPath=`"C:\Program Files\dotnet\dotnet.exe`"") | Set-Content $hostConfigPath

Set-Location $buildFolder