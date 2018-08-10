$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

$params = @( "install", "--no-deps", "--install-option=`"--prefix=c:\tmpPackage`"", "--install-option=`"--install-scripts=c:\tmpPackage\bin\scripts`"", "--root=c:\", "c:\pkg\src\$env:PKG_NAME")
& "pip.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install package"
    exit -1
}
Copy-Item -force -Recurse "c:\tmpPackage\*" "$env:PKG_PATH\"

#new-item -force -itemtype directory -path "$LIB_INSTALL_DIR\dcos-installer" > $null
#new-item -ItemType  Junction -value "c:\opt\mesosphere\active\dcos-installer-ui\usr\"  -path "$LIB_INSTALL_DIR\dcos_installer\templates"

#new-item -force -itemtype directory -path "$env:PKG_PATH\bin\dcos-path" > $null
#Copy-Item "c:\pkg\extra\dcos-shell" "$env:PKG_PATH\bin\dcos-path\dcos-shell"
#new-item -ItemType SymbolicLink "$env:PKG_PATH\bin\dcos-path\dcos-shell" "$env:PKG_PATH\bin\dcos-shell"

#add-content "$env:PKG_PATH\bin\add_dcos_path.ps1" "$env:PATH=`"$env:PATH:c:\opt\mesosphere\bin\dcos-path`""

# Include the LICENSE and NOTICES.txt file
new-item -force -itemtype directory -path "$env:PKG_PATH\etc" > $null
Copy-Item "c:\pkg\src\$env:PKG_NAME/LICENSE" "$env:PKG_PATH\etc\LICENSE"
Copy-Item "c:\pkg\src\$env:PKG_NAME/NOTICE" "$env:PKG_PATH\etc\NOTICE"
