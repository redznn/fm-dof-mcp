using System;
using System.Reflection;
using System.Runtime.InteropServices;
using BepInEx.Unity.IL2CPP;

namespace FMBridge.Pump;

internal sealed class MainThreadTickPump : ITickPump
{
    public string Name => "MainThreadTick (DadMych fork)";

    public event Action Tick;

    // The DadMych macOS fork exposes IL2CPPChainloader.MainThreadTick, which
    // does not exist in stock BepInEx 6 (e.g. Windows). Bind by reflection so
    // this file compiles against stock BepInEx everywhere: on the fork the
    // event is found and subscribed, elsewhere IsSupported is false and
    // BridgePlugin falls back to WinHarmonyTickPump (ticks arrive via the
    // RepaintPanels Harmony prefix instead).
    private EventInfo _event;
    private Action _handler;

    public static bool IsSupported =>
        RuntimeInformation.IsOSPlatform(OSPlatform.OSX) && FindEvent() != null;

    private static EventInfo FindEvent() =>
        typeof(IL2CPPChainloader).GetEvent("MainThreadTick",
            BindingFlags.Public | BindingFlags.Static);

    public MainThreadTickPump()
    {
        _event = FindEvent();
        if (_event == null) return;
        _handler = OnMainThreadTick;
        _event.AddEventHandler(null, _handler);
    }

    private void OnMainThreadTick()
    {
        Tick?.Invoke();
    }

    public void Dispose()
    {
        try { _event?.RemoveEventHandler(null, _handler); } catch { }
        _event = null;
        _handler = null;
    }
}
