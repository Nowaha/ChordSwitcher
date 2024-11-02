using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace ChordSwitcher;

internal class FretButtonMod : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Minigames/Guitar/fret_button.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {

        // func _set_marker(_s, _f):
        var setMarker = new MultiTokenWaiter([
            t => t.Type == TokenType.PrFunction,
            t => t is IdentifierToken { Name: "_set_marker" },
            t => t is IdentifierToken { Name: "_s" },
            t => t is IdentifierToken { Name: "_f" },
        ], allowPartialMatch: true);

        foreach (var token in tokens)
        {
            if (setMarker.Check(token))
            {
                yield return token;

                // , _c
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("_c");
            }
            else
            {
                // return the original token
                yield return token;
            }
        }
    }
}
