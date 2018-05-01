$ErrorActionPreference = "stop"
# Mesos configurationsG
$MESOS_DIR = "c:\mesos-tmp"
$MESOS_BUILD_DIR = Join-Path $MESOS_DIR "build"
$MESOS_GIT_REPO_DIR = Join-Path $MESOS_DIR "mesos"

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
    # Ninja builds Mesos faster, but we are still ironing out the kinks
    $buildNinja = $false
    try {
        if ($buildNinja) {
            # options to use Ninja 
            $parameters = @("$MESOS_GIT_REPO_DIR", "-G", "Ninja", "-DENABLE_LIBEVENT=1", "-DCMAKE_BUILD_TYPE=Release")
        } else {
            # msbuild options
            $generatorName = "Visual Studio 15 2017 Win64"
            $parameters = @("$MESOS_GIT_REPO_DIR", "-G", "`"$generatorName`"", "-T", "host=x64", "-DENABLE_LIBEVENT=1")
        }

        Wait-ProcessToFinish -ProcessPath "cmake.exe" -ArgumentList $parameters 
    } finally {
        Pop-Location
    }
    Write-Output "mesos cmake makefiles were generated successfully"

    Write-Output "Started building Mesos binaries"
    Push-Location $MESOS_BUILD_DIR
    try {
        if ($buildNinja) {
            # options to use Ninja
            $parameters = @("--build", ".", "--target", "mesos-agent")
        } else {
            # msbuild options
            $parameters =  @("--build", ".", "--config", "Release", "--target", "mesos-agent", "--", "/maxcpucount")
        }

        Wait-ProcessToFinish -ProcessPath "cmake.exe" -ArgumentList $parameters 
    } finally {
        Pop-Location
    }
    Write-Output "Mesos binaries were successfully built"
}

# copy source to temporary build directory
copy-item -Recurse "c:/pkg/src/" -destination "$MESOS_DIR"

New-Item -ItemType Directory -Path $MESOS_BUILD_DIR > $null

Start-MesosBuild

#Copy result binaries to destination directory. 
New-Item -itemtype directory "$env:PKG_PATH\bin" > $null
Copy-Item -Path "$MESOS_BUILD_DIR\src\*" -Destination "$env:PKG_PATH\bin\" -Filter "*.exe"


$systemd_slave="$env:PKG_PATH\dcos.target.wants_slave\dcos-mesos-slave.service"
$systemd_slave_dir = Split-Path $systemd_slave
New-Item -ItemType Directory -Force $systemd_slave_dir > $null
Copy-Item "c:\pkg\extra\dcos-mesos-slave.windows.service" $systemd_slave

$systemd_slave_public="$env:PKG_PATH\dcos.target.wants_slave_public\dcos-mesos-slave-public.service"
$systemd_slave_public_dir = Split-Path $systemd_slave_public
New-Item -ItemType Directory -Force $systemd_slave_public_dir > $null
Copy-Item "c:\pkg\extra\dcos-mesos-slave-public.windows.service" $systemd_slave_public
