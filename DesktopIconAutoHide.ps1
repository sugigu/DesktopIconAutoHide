# DesktopIconAutoHide.ps1
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = 'AboveNormal'
$idleSeconds = 10
$pollMs = 8   # 約 120fps

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class UserInput
{
    [StructLayout(LayoutKind.Sequential)]
    struct LASTINPUTINFO
    {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static uint GetIdleMilliseconds()
    {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);

        if (!GetLastInputInfo(ref lii))
        {
            return 0;
        }

        return ((uint)Environment.TickCount - lii.dwTime);
    }
}
"@

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class DesktopIcons
{
    [DllImport("user32.dll")]
    static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    static extern IntPtr FindWindowEx(
        IntPtr parent,
        IntPtr childAfter,
        string className,
        string windowName);

    [DllImport("user32.dll")]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    static extern bool IsWindow(IntPtr hWnd);

    public static IntPtr GetDesktopListView()
    {
        IntPtr progman = FindWindow("Progman", null);

        IntPtr defView = FindWindowEx(
            progman,
            IntPtr.Zero,
            "SHELLDLL_DefView",
            null);

        if (defView == IntPtr.Zero)
        {
            IntPtr worker = IntPtr.Zero;

            while ((worker = FindWindowEx(
                IntPtr.Zero,
                worker,
                "WorkerW",
                null)) != IntPtr.Zero)
            {
                defView = FindWindowEx(
                    worker,
                    IntPtr.Zero,
                    "SHELLDLL_DefView",
                    null);

                if (defView != IntPtr.Zero)
                {
                    break;
                }
            }
        }

        if (defView == IntPtr.Zero)
        {
            return IntPtr.Zero;
        }

        return FindWindowEx(
            defView,
            IntPtr.Zero,
            "SysListView32",
            "FolderView");
    }

    public static bool IsValidWindow(IntPtr hWnd)
    {
        return hWnd != IntPtr.Zero && IsWindow(hWnd);
    }

    public static void Show(IntPtr hWnd)
    {
        if (IsValidWindow(hWnd))
        {
            ShowWindow(hWnd, 5);
        }
    }

    public static void Hide(IntPtr hWnd)
    {
        if (IsValidWindow(hWnd))
        {
            ShowWindow(hWnd, 0);
        }
    }
}
"@

$listView = [DesktopIcons]::GetDesktopListView()
$visible = $true
$idleLimitMs = $idleSeconds * 1000

Write-Host "Desktop icon auto hide running..."
Write-Host "Idle threshold : $idleSeconds sec"
Write-Host "Polling        : $pollMs ms"

while ($true)
{
    if (-not [DesktopIcons]::IsValidWindow($listView))
    {
        $listView = [DesktopIcons]::GetDesktopListView()
    }

    $idleMs = [UserInput]::GetIdleMilliseconds()

    # 有輸入，立刻顯示
    if ($idleMs -lt $pollMs)
    {
        if (-not $visible)
        {
            [DesktopIcons]::Show($listView)
            $visible = $true
        }
    }

    # 閒置超過設定秒數，隱藏
    elseif ($visible -and $idleMs -ge $idleLimitMs)
    {
        [DesktopIcons]::Hide($listView)
        $visible = $false
    }

    Start-Sleep -Milliseconds $pollMs
}