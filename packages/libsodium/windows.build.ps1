$ErrorActionPreference = "stop"
$LIB_SODIUM_DIR = "c:\libsodium"

function Set-WindowsSDK {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$VCXProjFile,
        [Parameter(Mandatory=$true)]
        [string]$Version
    )

    [xml]$settings = Get-Content $VCXProjFile
    $target = $settings.Project.PropertyGroup | Where-Object { $_.Label -eq "Globals" }
    if($target.WindowsTargetPlatformVersion) {
        $target.WindowsTargetPlatformVersion = $Version
    } else {
        $element = $settings.CreateElement('WindowsTargetPlatformVersion', $settings.DocumentElement.NamespaceURI)
        $element.InnerText = $Version
        $target.AppendChild($element) | Out-Null
    }
    $settings.Save($VCXProjFile)
}


function Wait-ProcessToFinish {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$ProcessPath,
        [Parameter(Mandatory=$false)]
        [String[]]$ArgumentList,
        [Parameter(Mandatory=$false)]
        [int]$Timeout=7200
    )
    $parameters = @{
        'FilePath' = $ProcessPath
        'NoNewWindow' = $true
        'PassThru' = $true
    }
    if ($ArgumentList.Count -gt 0) {
        $parameters['ArgumentList'] = $ArgumentList
    }
    $process = Start-Process @parameters
    $errorMessage = "The process $ProcessPath didn't finish successfully"
    try {
        Wait-Process -InputObject $process -Timeout $Timeout -ErrorAction Stop
        Write-Output "Process finished within the timeout of $Timeout seconds"
    } catch [System.TimeoutException] {
        Write-Output "The process $ProcessPath exceeded the timeout of $Timeout seconds"
        Stop-Process -InputObject $process -Force -ErrorAction SilentlyContinue
        Throw $_
    }
    if($process.ExitCode -ne 0) {
        Write-Output "$errorMessage. Exit code: $($process.ExitCode)"
        Throw $errorMessage
    }
}

function Start-LIB_SODIUMBuild {
    Write-Output "Building LibSodium"

    Push-Location $LIB_SODIUM_DIR

    # patch the project file to use the correct SDK
    Set-WindowsSDK -VCXProjFile "$LIB_SODIUM_DIR\builds\msvc\vs2017\libsodium\libsodium.vcxproj" -Version "10.0.16299.0"
    
    try {
        # msbuild options
        # We want the dynamic libary rather than static.
        $parameters = @("$LIB_SODIUM_DIR\builds\msvc\vs2017\libsodium.sln", '/nologo', '/target:Build', '/p:Platform=x64', '/p:Configuration="DynRelease"')
        Wait-ProcessToFinish -ProcessPath "msbuild.exe" -ArgumentList $parameters 
    } finally {
        Pop-Location
    }
    Write-Output "LIB_SODIUM binaries were successfully built"
}

# copy source to temporary build directory
copy-item -Recurse "c:/pkg/src/libsodium" -destination "c:\"


Start-LIB_SODIUMBuild

#Copy result binaries to destination directory. 
New-Item -itemtype directory "$env:PKG_PATH\bin" -ErrorAction SilentlyContinue > $null
New-Item -itemtype directory "$env:PKG_PATH\lib" -ErrorAction SilentlyContinue > $null
New-Item -itemtype directory "$env:PKG_PATH\include" -ErrorAction SilentlyContinue > $null
Copy-Item -Path "$LIB_SODIUM_DIR\bin\x64\Release\v141\dynamic\*" -Destination "$env:PKG_PATH\bin\" -filter "*.dll"
Copy-Item -Path "$LIB_SODIUM_DIR\bin\x64\Release\v141\dynamic\*" -Destination "$env:PKG_PATH\lib\" -Filter "*.lib"
Copy-Item -recurse -Path "$LIB_SODIUM_DIR\src\libsodium\include\*" -Destination "$env:PKG_PATH\include\" 


