# ChordSwitcher
A simple WEBFISHING mod that allows you to easily save and load multiple chord sets! This makes it a lot easier to play multiple songs or store more than just 9 chords.

## Features
- **Easy chord list switching:** Save up to 9 chord sets with 9 chords each!
- **Persistent:** You can save and load the chords from a file when you choose!
- **Export/Import/Share:** You can share the `custom_chords.json` file with others to help others play your songs!

## Keybinds
- `F1`-`F9`: load chord set 1-9
- `CTRL` + `F1`-`F9`: save configuration 1-9
- `SHIFT` + `F10`: load all chord sets from file
- `SHIFT` + `F11`: save all chord sets to file

## Files
This project writes/reads a single file to the same directory as your WEBFISHING save file, to `custom_files.json`.

## Installation
> **NOTE:** GDWeave is required to use the mod, which can be found [here](https://github.com/NotNite/GDWeave/) if you do not have it yet.

[Download the latest release](https://github.com/Nowaha/ChordSwitcher/releases/latest/download/ChordSwitcher.zip) and extract it inside of your `GDWeave/mods` folder, so that it exists as a normal folder in there alongside your other mods.

You should end up with this structure:
```
GDWeave/
  mods/
    ChordSwitcher/
      ChordSwitcher.pck
      manifest.json
```
