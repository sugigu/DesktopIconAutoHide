# Desktop Icon Auto Hide
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/github/license/sugigu/DesktopIconAutoHide)

PowerShell script to automatically hide Windows desktop icons after 10 seconds of user inactivity. OLED-friendly.

## Features

- Hides desktop icons after a configurable idle timeout
- Shows desktop icons immediately after user input
- Uses Win32 API calls through PowerShell `Add-Type`
- No external dependencies
- Works with the normal Windows desktop `SysListView32` icon view
- Lightweight polling loop, defaulting to 8 ms polling

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or PowerShell 7+

## Usage

Download `DesktopIconAutoHide.ps1`, then run it in PowerShell:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DesktopIconAutoHide.ps1
```

Or with PowerShell 7:

```powershell
pwsh.exe -ExecutionPolicy Bypass -File .\DesktopIconAutoHide.ps1
```

The script will keep running until the PowerShell window is closed.

## Configuration

Edit these values near the top of `DesktopIconAutoHide.ps1`:

```powershell
$idleSeconds = 10
$pollMs = 8
```

| Setting | Description |
| --- | --- |
| `$idleSeconds` | How many seconds of inactivity before desktop icons are hidden |
| `$pollMs` | How often the script checks for input, in milliseconds |

Common polling values:

| Target | `$pollMs` |
| --- | ---: |
| 60 fps-ish | `16` |
| 120 fps-ish | `8` |
| Lower CPU usage | `33` |

The default `8 ms` polling is intentionally aggressive so icons reappear quickly. If your machine starts acting like it has discovered suffering, increase this value.

## Run at login

To run automatically when you sign in, create a scheduled task:

1. Open **Task Scheduler**.
2. Choose **Create Task**.
3. On **General**, select **Run only when user is logged on**.
4. On **Triggers**, add **At log on**.
5. On **Actions**, add:

```text
Program/script:
powershell.exe

Add arguments:
-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Path\To\DesktopIconAutoHide.ps1"
```

Replace the path with wherever you put the script. Revolutionary stuff, paths needing to be correct.

## Notes

This script finds the desktop icon list view by locating `SHELLDLL_DefView` under either `Progman` or `WorkerW`, then toggles the `SysListView32` window with `ShowWindow()`.

It only hides the desktop icon view. It does not delete icons, rearrange them, or perform other desktop crimes.

## License

MIT License. See [LICENSE](LICENSE).
