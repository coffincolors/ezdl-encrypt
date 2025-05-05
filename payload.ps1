<# ===============================================================
 Replace the contents of this file with script you want to encrypt
 =============================================================== #>

Invoke-WebRequest -Uri "https://ninite.com/7zip/ninite.exe" -OutFile "$env:TEMP\ninite.exe"; Start-Process "$env:TEMP\ninite.exe"