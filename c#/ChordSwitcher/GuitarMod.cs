using System.Runtime.CompilerServices;
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

        // signal _fret_update(string, fret)
        //                         target ^
        var signalFretUpdate = new MultiTokenWaiter([
            t => t.Type == TokenType.PrSignal,
            t => t is IdentifierToken { Name: "_fret_update" },
            t => t is IdentifierToken { Name: "string" },
            t => t is IdentifierToken { Name: "fret" },
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

        // func _select_shape(shape):
	    //   selected_shape = shape
	    //   for i in 6: _select_fret(i, saved_shapes[shape][i], true)
        //                                                   target ^
        var selectShapeLoop = new MultiTokenWaiter([
            t => t.Type == TokenType.PrFunction,
            t => t is IdentifierToken { Name: "_setup_guitar" },
            t => t is IdentifierToken { Name: "_select_shape" },
            t => t is IdentifierToken { Name: "_setup_guitar" },
            t => t is IdentifierToken { Name: "_select_shape" },
            t => t.Type == TokenType.Constant,
            t => t.Type == TokenType.Constant,
        ], allowPartialMatch: true);

        // _select_fret(string, fret, ignore_overwrite = false):
        //                                            target ^
        var selectFretArgs = new MultiTokenWaiter([
            t => t.Type == TokenType.PrFunction,
            t => t is IdentifierToken { Name: "_select_fret" },
            t => t is IdentifierToken { Name: "string" },
            t => t is IdentifierToken { Name: "fret" },
            t => t is IdentifierToken { Name: "ignore_overwrite" },
            t => t.Type == TokenType.Constant,
        ], allowPartialMatch: true);

        // emit_signal("_fret_update", string, fret)
        // ^  target
        var emitSignal = new MultiTokenWaiter([
            t => t is IdentifierToken { Name: "ignore_overwrite" },
            t => t is IdentifierToken { Name: "emit_signal" },
        ], allowPartialMatch: true);

        var postEmitSignal = new MultiTokenWaiter([
            t => t is IdentifierToken { Name: "emit_signal" },
            t => t is IdentifierToken { Name: "saved_shapes" },
            t => t is IdentifierToken { Name: "fret" },
            t => t.Type == TokenType.Newline,
        ], allowPartialMatch: true);

        int skip = 0;
        foreach (var token in tokens)
        {
            if (skip-- > 0) continue;
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
            else if (signalFretUpdate.Check(token))
            {
                yield return token;

                // , is_chord
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("is_chord");
            }
            else if (selectFretArgs.Check(token))
            {
                yield return token;

                // , is_chord = false
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("is_chord");
                yield return new Token(TokenType.OpAssign);
                yield return new ConstantToken(new BoolVariant(false));
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
            else if (selectShapeLoop.Check(token)) {
                yield return token;

                // , true
                yield return new Token(TokenType.Comma);
                yield return new ConstantToken(new BoolVariant(true));
            } else {
                if (postEmitSignal.Check(token)) {
                    yield return new Token(TokenType.Newline, 1);
                   
                    // emit_signal("_fret_update", string, fret, is_chord)
                    yield return new IdentifierToken("emit_signal");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new ConstantToken(new StringVariant("_fret_update"));
                    yield return new Token(TokenType.Comma);
                    yield return new IdentifierToken("string");
                    yield return new Token(TokenType.Comma);
                    yield return new IdentifierToken("fret");
                    yield return new Token(TokenType.Comma);
                    yield return new IdentifierToken("is_chord");
                    yield return new Token(TokenType.ParenthesisClose);
                    yield return new Token(TokenType.Newline);
                    continue;
                }
                if (emitSignal.Check(token))
                {
                    skip = 7; // Clear the inital emit_signal line
                }
                else
                {
                    // return the original token
                    yield return token;
                }
            }
        }
    }
}
