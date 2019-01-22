$destPathMST = 'D:\Microsoft.TestPlatform'
$destSource = 'D:\Source'
$configuration = 'Debug'

$vstestPath = Get-ChildItem -Path $destPathMST -Recurse -Filter "vstest.console.exe"
Write-Host "vstest = " $vstestPath.FullName

#UI-Tests
$testprojectFiles = Get-ChildItem -Path $destSource\UITests -Directory

foreach ($testprojectFile in $testprojectFiles) {
    write-host $testprojectFile.Name 
    $PathToCurrentTest = Get-ChildItem -Path $($testprojectFile.FullName + '\' + $configuration + '\') -Filter $(($testprojectFile.Name) + ".UI.Tests.dll")
    write-host $PathToCurrentTest.FullName
        & $vstestPath.FullName $PathToCurrentTest.FullName /Enablecodecoverage
        if (! $?) { 
            Write-Host "UI-Tests FAILED."
            Exit 1
    }
}