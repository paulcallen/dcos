$ErrorActionPreference = "stop"
# Mesos configurationsG
$MESOS_DIR = "c:\mesos-tmp"
$MESOS_BUILD_DIR = Join-Path $MESOS_DIR "build"
$MESOS_GIT_REPO_DIR = Join-Path $MESOS_DIR "mesos"
$MESOS_BUILD_OUT_DIR = Join-Path $MESOS_DIR "build-output"

function New-Directory {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [switch]$RemoveExisting
    )
    if(Test-Path $Path) {
        if($RemoveExisting) {
            # Remove if it already exist
            Remove-Item -Recurse -Force $Path
        } else {
            return
        }
    }
    return (New-Item -ItemType Directory -Path $Path)
}

function New-Environment {
    Write-Output "Creating new tests environment"
    New-Directory $MESOS_BUILD_DIR
    New-Directory $MESOS_BUILD_OUT_DIR -RemoveExisting
    Write-Output "New tests environment was successfully created"
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

function Start-MesosBuild {
    Write-Output "Creating mesos cmake makefiles"
    Push-Location $MESOS_BUILD_DIR
    try {
        $generatorName = "Visual Studio 15 2017 Win64"
        $parameters = @("$MESOS_GIT_REPO_DIR", "-G", "`"$generatorName`"", "-T", "host=x64", "-DENABLE_LIBEVENT=1")

        Wait-ProcessToFinish -ProcessPath "cmake.exe" -ArgumentList $parameters 
    } finally {
        Pop-Location
    }
    Write-Output "mesos cmake makefiles were generated successfully"

    Write-Output "Started building Mesos binaries"
    Push-Location $MESOS_BUILD_DIR
    try {
        $parameters =  @("--build", ".", "--config", "Release", "--target", "mesos-agent", "--", "/maxcpucount")
        Wait-ProcessToFinish -ProcessPath "cmake.exe" -ArgumentList $parameters
    } finally {
        Pop-Location
    }
    Write-Output "Mesos binaries were successfully built"
}


copy-item -Recurse "c:/pkg/src/" -destination "$MESOS_DIR"

New-Environment

Start-MesosBuild

#Copy build directory to destination directory. 
#For now we grab the whole lot
New-Item -itemtype directory "$env:PKG_PATH\bin"
Copy-Item -Path "$MESOS_BUILD_DIR\src\*" -Destination "$env:PKG_PATH\bin\" -Filter "*.exe"
