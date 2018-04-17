New-Item -ItemType Directory "$env:PKG_PATH\bin" > $null
"echo %0 %*" | out-file -Encoding ascii "$env:PKG_PATH\bin\systemctl.cmd"