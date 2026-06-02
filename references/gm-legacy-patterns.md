# Legacy Game Maker Migration Patterns

This reference collects migration patterns that have generalized across legacy Game Maker projects. Keep project-only discoveries in the target repository unless they expose a reusable pattern.

## Preserve First

- Do not edit original GM4/GM5 source archives unless explicitly requested.
- Create derived conversion artifacts instead of overwriting preserved files.
- Keep diffs small; avoid cosmetic cleanup while fixing migration problems.

## Common Compile Errors

### Duplicate resource names after import

Symptom:

```text
Sprite name "abajo" is used twice.
Sprite name "movAbajo" is used twice.
```

Runtime signs:

- objects show another character's sprite
- movement/idle sprites change into enemy sprites
- generic names like `abajo`, `arriba`, `derecha`, `izquierda`, `normal`, and `mov*` resolve unpredictably

Cause:

- Older Game Maker projects could contain same-named resources in different folders or contexts.
- GMS1.4 flattens resource identifiers enough that same-name sprites collide.

Fix strategy:

- Do not mass-rename every collision at once.
- Start with the visible broken object.
- Inspect the object event assignments and the actual sprite images.
- If the intended sprite already survived under another resource name, update only the broken object's references.
- If both resources are needed, create explicit unique names and update all references for one resource family.
- If HTML5 export reports duplicate `.tpe` names, check whether the same `<sprite>sprites\...</sprite>` path appears multiple times in the `.project.gmx` resource tree. Remove duplicate project-tree entries without deleting the sprite files.
- Treat a compile/run success as insufficient. Visually validate the affected character or object in browser after relinking sprites.
- If the object still displays the wrong sprite, mark the first relink attempt as unresolved and continue tracing resource collisions.
- Document each resource-family decision in the project dev log.

Preservation warning:

- Project tree entries are not the same as source resource files.
- Removing a duplicate `<sprite>` or `<object>` path from `.project.gmx` should only remove duplicate metadata, not the underlying `.sprite.gmx`, `.object.gmx`, or image files.
- Preserve known gameplay resources such as player spell families, character movement families, menu controllers, cutscene controllers, rooms, sounds, and endings until their behavior and references have been validated.

Rename convention:

When a resource must be renamed to resolve a collision, use a two-character prefix plus underscore and keep the original Spanish/descriptive name after it where possible.

| Prefix | Resource type |
| --- | --- |
| `sp_` | Sprite |
| `ob_` | Object |
| `rm_` | Room |
| `so_` | Sound |
| `bg_` | Background |
| `sc_` | Script |
| `fo_` | Font |
| `pa_` | Path |
| `ti_` | Timeline |
| `sh_` | Shader |
| `ex_` | Extension |

Examples: `sp_magicIce`, `rm_icePalace`, `ob_player`, `so_song`.

Use this convention for explicit collision fixes and new migration helper resources. Do not mass-rename historical resources only to normalize style.

Post-rename check:

- Reopen/save cycles in GMS1.4 may leave or restore stale literal resource names inside imported Drag and Drop action XML.
- After each resource rename, search the active project for the old resource name, especially in `.object.gmx` action arguments such as `<room>oldName</room>`, `<sprite>oldName</sprite>`, and `<background>oldName</background>`.
- If the worktree is staged, compare both the working file and staged/index copy before committing.
- Project-wide resource renames must be type-aware. Do not run a blind token replacement across all resources, because the same legacy name may exist as multiple resource types, such as room, background, sprite, object, script, or sound.
- Validate after a rename batch by checking project entries, resource files, sprite/background media paths, sound audio paths, room instances/views/backgrounds, object event references, and duplicate resource names.

Startup recovery checklist after rename batch:

- Reopen the project in GMS1.4 and capture every missing-resource dialog item before editing.
- Check imported Drag and Drop Execute Script action arguments first. Stale names often come from renamed scripts, scripts with spaces, built-in-shadowing scripts, resource collisions, or placeholder imports such as `obsolete`.
- Replace stale `<script>...</script>` and `functionname` values with the prefixed script resource names.
- Scan for residual numeric or legacy sprite names in object headers (for example `spriteName` values such as `1`) and relink to prefixed resources (for example `sp_1`).
- Reopen again after each small batch until startup dialogs disappear, then continue with compile/runtime validation.

### Script shadows a built-in

Symptom:

```text
wrong number of arguments for function random
```

Cause:

- A legacy script named `random` shadows the built-in `random(max)`.

Fix:

- Rename the script, for example `random_move`.
- Update project script references and imported Execute Script action references.

### Script name contains spaces

Symptom:

```text
unknown function or script opciones
```

Cause:

- A script such as `pantalla opciones` is tokenized as separate identifiers.

Fix:

- Rename to an identifier-safe form such as `pantalla_opciones`.
- Update all script references.

### Imported obsolete action

Symptom:

```text
unknown function or script obsolete
```

Cause:

- Old DnD actions such as sleep/wait imported as a placeholder action function.

Compile-phase fix:

```gml
show_debug_message("TODO MIGRATION: Legacy obsolete action skipped");
```

Runtime follow-up:

- Replace with non-blocking state, Step, Draw, Alarm, or controller logic.

### Broken movement DnD action

Symptom:

```text
wrong number of arguments for function action_move
```

If the action appears to stop movement:

```gml
hspeed = 0;
vspeed = 0;
speed = 0;
```

If the action starts motion, preserve the direction/speed from the imported arguments.

### Broken object creation DnD action

Symptom:

```text
wrong number of arguments for function action_create_object
```

Fix only after identifying:

- object resource
- x/y offsets
- whether coordinates are relative
- event context

Conservative blank numeric offsets can often become `0`, but document uncertainty.

## Drawing API

For old scaled sprite calls, prefer:

```gml
draw_sprite_ext(sprite, subimg, x, y, xscale, yscale, 0, c_white, 1);
```

Preserve sprite, subimage, position, scale, rotation, color, and alpha when known.
