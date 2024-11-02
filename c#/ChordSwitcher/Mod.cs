using GDWeave;

namespace ChordSwitcher;

public class Mod : IMod {

    public Mod(IModInterface modInterface) {
        modInterface.RegisterScriptMod(new FretButtonMod());
        modInterface.RegisterScriptMod(new GuitarMod());
    }

    public void Dispose() {
        // Cleanup anything you do here
    }
}
