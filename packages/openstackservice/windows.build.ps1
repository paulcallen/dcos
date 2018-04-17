$ErrorActionPreference = "stop"
copy-item -recurse  "c:\pkg\src\openstackservice" -destination "c:\"
push-location "c:\openstackservice"
nuget restore openstackservice.sln
msbuild openstackservice.sln /p:configuration=release /property:Configuration="SDK10Release"
new-item -itemtype directory "$env:PKG_PATH\bin"
copy-item "C:\openstackservice\SDK10Release\OpenStackService.exe" -destination "$env:PKG_PATH\bin"

