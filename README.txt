EZDL-Encrypt quick‑start
=======================

Files in this folder
--------------------
  * payload.ps1      – put the PowerShell script you want protected here
  * ezdl-encrypt.ps1 – does the AES‑256 encryption & builds secure_loader.ps1
  * Start.cmd        – friendly wrapper that runs the encryptor for you
                      (pure ASCII; save the file itself as ANSI or UTF‑8 *without* BOM)

How to use
----------
1. Edit payload.ps1 and paste in the script you want to distribute.

2. Double‑click Start.cmd
   • The batch file checks that payload.ps1 and ezdl-encrypt.ps1 exist.
   • You’re prompted for a passphrase – this becomes the encryption key.
   • A fresh secure_loader.ps1 is generated in the same folder.

3. (Optional) Open secure_loader.ps1 in a text editor if you wish to inspect it.

4. Copy the *contents* of secure_loader.ps1 to a GitHub Gist (or any host),
   then point your ezdl.info forwarding sub‑domain at that raw URL, e.g.

      irm mytool.ezdl.info | iex

   Users will be prompted for the same passphrase before the payload runs.

Rollback / troubleshooting
--------------------------
* The encryption step never modifies your original payload.ps1.
* If you want to change the payload or pick a new passphrase, simply
  overwrite payload.ps1 (and/or delete secure_loader.ps1) and run Start.cmd
  again.
* If the batch file prints “<text> was unexpected at this time”, make sure
  Start.cmd is still plain ASCII and re‑save it as ANSI or UTF‑8 (no BOM).
