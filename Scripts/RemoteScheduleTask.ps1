cls
$destPathMST = 'D:\Microsoft.TestPlatform'
$destPathMSTzip = 'D:\Microsoft.TestPlatform.zip'
$destSource = 'D:\Source'
$destSourcezip = 'D:\Source.zip'
$executableFile = 'D:\UITests_Remote.ps1'

#Save UI-tests output's messages to file 
$currDatePath = $((Get-Date).ToString('yyyy_MM_dd_HHmm'))
$outputFile = 'D:\UItests' + $currDatePath + '.txt' 

$executable = "-Command ""& $executableFile 2>&1 > $outputFile"""
$action = New-ScheduledTaskAction -Execute 'powershell' -Argument $executable

$userFullName = 'UI-VM\admin1803'
$stPrin = New-ScheduledTaskPrincipal -UserId $userFullName -RunLevel Highest -LogonType Interactive

$task = New-ScheduledTask -Action $action -Principal $stPrin
$taskname = "_StartProcessActiveTask"

#unregister Task if exists
try {
   $registeredTask = Get-ScheduledTask $taskname -ErrorAction SilentlyContinue
} 
catch {
   $registeredTask = $null
}
if ($registeredTask) {
    Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
}

#Remove All Files except Source.zip and Script that perform 
$deletedir = 'D:\'
get-childitem $deletedir |? { -not ($_.FullName -Like $destSourcezip -or $_.FullName -Like $executableFile)} | remove-item  -Force -Recurse

#Get Microsoft.TestPlatform and unzip
Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.TestPlatform/15.9.0" -OutFile $destPathMSTzip
Expand-Archive -Path $destPathMSTzip -DestinationPath $destPathMST -Force

#Remove escape characters from Microsoft.TestPlatform directories
$items = Get-ChildItem $destPathMST -Directory -Recurse | Where-Object {($_.Name -Like "*%*")} | sort fullname -descending

foreach  ($item in $items) {
    Rename-Item -Path $item.FullName -NewName $([Uri]::UnescapeDataString($item.Name)) -ErrorAction Stop
    Write-Host 'Start Test'  $([Uri]::UnescapeDataString($item.Name))
}

#Unzip sources
Expand-Archive -Path $destSourcezip -DestinationPath $destSource -Force

#Register, start and remove Task
$registeredTask = $task | Register-ScheduledTask $taskname

Start-ScheduledTask -InputObject $registeredTask

Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false