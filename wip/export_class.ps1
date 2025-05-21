Start-Process -FilePath "C:\Program Files\WinRAR\WinRAR.exe" -ArgumentList "a -r -ep1 new_class.zip .\new_class\*" -Wait

if (Test-Path -Path new_class.poodle) {
    Remove-Item -Path new_class.poodle -Force
}

# Renombramos el archivo ZIP a extensión .poodle
Rename-Item -Path new_class.zip -NewName new_class.poodle -Force