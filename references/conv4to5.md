# Conv4to5 GM4 to GM5 Converter

Use this reference when a migration starts from a Game Maker 4.x `.gmd` file and needs a Game Maker 5.0 `.gmd` intermediary before importing into GameMaker Studio 1.4 or later.

## Bundled Tool

For internal distribution, this skill bundles the recovered converter at:

```text
assets/tools/conv4to5.zip
```

Archive contents:

- `Conv4to5.exe`
- `Readme.txt`

Known archive metadata:

- Size: `362856` bytes
- SHA-256: `255973a7532a84e98b28a53ab573be84e4437389fec40ab1209db3bceae960e8`
- Original readme author line: `Mark Overmars`

Licensing note:

- The bundled copy is intended for internal restoration/migration use.
- The readme explains usage but does not include an explicit redistribution license.
- Before public distribution, either confirm redistribution rights or remove the binary and document a bring-your-own-tool workflow with this checksum.

## Conversion Workflow

1. Preserve the original GM4 `.gmd` unchanged.
2. Extract `assets/tools/conv4to5.zip` into a temporary working folder.
3. Run `Conv4to5.exe` on Windows, Wine, or a VM.
4. Choose the original Game Maker 4.x file as input.
5. Write the converted Game Maker 5.0 file to a new filename.
6. Keep both the original GM4 file and the converted GM5 file as historical artifacts.
7. Import or open the GM5 file in the next migration stage.
8. Document the source file, output file, tool checksum, and any conversion warnings in the project migration log.

Do not overwrite the original `.gmd`. If the converter fails or the output behaves differently from a reference build, document the discrepancy before changing migration behavior.

## Practical Notes

- Game Maker 5.1 may not read Game Maker 4.x files directly, which is why this converter is useful.
- Prefer running the converter in an isolated folder so generated files are easy to identify.
- If the converter UI is unavailable in the current environment, ask the user to run it locally and provide the converted GM5 `.gmd` plus any observed warnings.
- Treat the converted GM5 file as a derived artifact, not as proof that every resource imported correctly.
