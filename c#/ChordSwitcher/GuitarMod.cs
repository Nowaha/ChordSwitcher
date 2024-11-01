using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace ChordSwitcher;

internal class GuitarMod : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Minigames/Guitar/guitar_minigame.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        var topOfFile = new MultiTokenWaiter([
            t => t.Type == TokenType.Newline,
            t => t.Type == TokenType.Newline,
        ], allowPartialMatch: true);

        // func _ready():
        //   ...
        //   $AnimationPlayer.play("intro")
        //   <target> (bottom of _ready)
        var bottomOfReady = new MultiTokenWaiter([
            t => t.Type == TokenType.PrFunction,
            t => t is IdentifierToken { Name: "_ready" },
            t => t.Type == TokenType.Colon,
            t => t.Type == TokenType.Newline,
            t => t is IdentifierToken { Name: "AnimationPlayer" },
            t => t is IdentifierToken { Name: "play" },
            t => t.Type == TokenType.Newline,
        ], allowPartialMatch: true);

        foreach (var token in tokens)
        {
            if (topOfFile.Check(token))
            {
                yield return token;

                // onready var chordswitcher_mod = get_node("/root/ChordSwitcher")
                yield return new Token(TokenType.PrOnready);
                yield return new Token(TokenType.PrVar);
                yield return new IdentifierToken("chordswitcher_mod");
                yield return new Token(TokenType.OpAssign);
                yield return new IdentifierToken("get_node");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new ConstantToken(new StringVariant("/root/ChordSwitcher"));
                yield return new Token(TokenType.ParenthesisClose);
                yield return new Token(TokenType.Newline);
            }
            else if (bottomOfReady.Check(token))
            {
                yield return new Token(TokenType.Newline, 1);

                // chordswitcher_mod._inject(self)
                yield return new IdentifierToken("chordswitcher_mod");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("_inject");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new Token(TokenType.Self);
                yield return new Token(TokenType.ParenthesisClose);
                yield return new Token(TokenType.Newline, 1);
            }
            else
            {
                // return the original token
                yield return token;
            }
        }
    }
}
