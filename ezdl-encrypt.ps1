<#
 ────────────────────────────────────────────────────────────────
  encrypt_payload.ps1
  · Put the script you want protected into  .\payload.ps1
  · Run this script, enter a passphrase, receive secure_loader.ps1
 ────────────────────────────────────────────────────────────────
#>

# 1. Prompt for passphrase
$securePass  = Read-Host 'Enter passphrase to encrypt payload' -AsSecureString
$passphrase  = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
               )

# 2. Load payload
$payloadPath = 'payload.ps1'
if (-not (Test-Path $payloadPath)) { Write-Error 'payload.ps1 not found' ; exit 1 }
$payloadBytes = [System.Text.Encoding]::UTF8.GetBytes( (Get-Content $payloadPath -Raw) )

# 3. Derive 32‑byte AES key
$key = [System.Text.Encoding]::UTF8.GetBytes( $passphrase.PadRight(32,'X') )[0..31]

# 4. Random IV
$iv = New-Object byte[] 16
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($iv)

# 5. Encrypt
$aes              = [Security.Cryptography.Aes]::Create()
$aes.Mode         = 'CBC'
$aes.Padding      = 'PKCS7'
$aes.Key, $aes.IV = $key, $iv
$cipherBytes      = $aes.CreateEncryptor().TransformFinalBlock($payloadBytes,0,$payloadBytes.Length)

# 6. Base‑64( IV || CipherText )
$base64Payload = [Convert]::ToBase64String( $iv + $cipherBytes )

# 7. Loader template
$loaderTemplate = @'
# Prompt for passphrase
$securePass = Read-Host 'Enter passphrase' -AsSecureString
$passphrase = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
              )

# Derive key
$key = [System.Text.Encoding]::UTF8.GetBytes($passphrase.PadRight(32,'X'))[0..31]

# Encrypted payload (IV + ciphertext, Base-64)
$data = [Convert]::FromBase64String('@BASE64@')

# Split IV / cipher
$iv     = $data[0..15]
$cipher = $data[16..($data.Length-1)]

# Decrypt
$aes              = [Security.Cryptography.Aes]::Create()
$aes.Mode         = 'CBC'
$aes.Padding      = 'PKCS7'
$aes.Key, $aes.IV = $key, $iv
$plainBytes       = $aes.CreateDecryptor().TransformFinalBlock($cipher,0,$cipher.Length)

# Run payload
Invoke-Expression ([System.Text.Encoding]::UTF8.GetString($plainBytes))
'@

# 8. Insert blob & write loader
$loaderTemplate.Replace('@BASE64@',$base64Payload) |
    Set-Content -Path 'secure_loader.ps1' -Encoding UTF8

Write-Host "`n[+] secure_loader.ps1 created successfully."
