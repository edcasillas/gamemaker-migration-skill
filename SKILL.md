---
name: gamemaker-migration-assistant
description: General workflow for migrating legacy Game Maker projects from GM4/GM5 .gmd files into GameMaker Studio 1.4 .gmx projects and onward to modern GameMaker or HTML5. Use when Codex is working on old Game Maker source recovery, GM4 to GM5 conversion, GMS1.4 imports, broken imported Drag and Drop actions, obsolete functions, MIDI/audio conversion for web export, browser export issues, resource-name collisions, or runtime validation of preserved legacy behavior.
---

# Migrate GM4/GM5/GMS1.4

Use this skill for legacy Game Maker migration work across projects. Keep project-specific discoveries in the target repository's docs or agent guidance unless they generalize across migrations.

This skill must remain generic and reusable across migrations. Do not encode
specific game names, named characters, rooms, factions, or repository-local
canon into the skill body or its durable references. If a migration produced a
useful lesson, generalize and anonymize it before keeping it here.

When writing durable migration documentation, keep it complete but concise.
Prefer short quickstarts, tables where they genuinely improve scanability, and
diagrams wherever they add real explanatory value.

Use it to preserve and migrate old Game Maker projects through:

1. Game Maker 4 `.gmd`
2. Game Maker 5 `.gmd`
3. GameMaker Studio 1.4 `.gmx`
4. Modern GameMaker / HTML5 export

If the migration starts from a Game Maker 4.x `.gmd`, read `references/conv4to5.md` for the bundled internal GM4 -> GM5 converter and preservation workflow.

## Optional Companion Skill

For current GameMaker command-line development, use the optional companion skill `gamemaker-development`.

Companion repository:

```text
https://github.com/edcasillas/gamemaker-development-skill
```

Install it as a direct checkout:

```sh
git clone https://github.com/edcasillas/gamemaker-development-skill.git .agents/skills/gamemaker-development
```

Or install it as a Git submodule:

```sh
git submodule add https://github.com/edcasillas/gamemaker-development-skill.git .agents/skills/gamemaker-development
```

Use `gamemaker-development` for current `.yyp` workflows, `gm-cli`, ResourceTool, GameMaker Manual lookup, compile/run/package automation, and GX.Games packaging or publishing. This companion skill is optional; this migration skill remains standalone for legacy preservation and migration work.

## Core Rules

- Preserve historical source files. Treat original `.gmd`, converter tools, archived assets, and reference builds as artifacts.
- Make migration edits in the active imported project, not the original recovered source, unless the user explicitly asks.
- Prefer small, reviewable fixes over broad rewrites.
- Preserve original behavior when it is clear.
- When behavior is unclear, add a searchable TODO/debug placeholder and document the follow-up.
- Hard rule: do not guess root causes for runtime/compile fixes. Require evidence from current logs plus exact object/event/script trace, or a reproducible path, before changing behavior.
- For web targets, avoid blocking waits, input loops, platform-specific filesystem assumptions, and thread-blocking timing behavior.
- Use meaningful, traceable names for migration helpers. Avoid vague names like `obsolete`/`tmp`/`fix`.
- If a required local tool is missing, do not silently switch to a weaker workflow. State the missing tool, ask whether it can be installed, and use a manual or limited fallback only if the user declines the install, the install fails, or the tool is unavailable for the current machine.
- Treat any named project, reference repo, character, room, spell, or resource below as an example unless the active repository explicitly defines it as local guidance.

## Workflow

1. Identify the active project and preservation boundary.
2. Identify the active migration hop, such as GM4 -> GM5, GM4/GM5 -> GMS1.4, GMS1.4 -> modern GameMaker, or modern GameMaker -> HTML5.
3. Read the latest compile log, browser console output, or user reproduction steps.
4. Map generated GMS error names back to source resources:
   - `gml_Object_<object>_<event>` usually maps to `objects/<object>.object.gmx`.
   - Generated event line numbers often point to imported action blocks, not a visible editor error.
5. Inspect the object event/action XML or script file directly.
6. Infer original behavior from nearby actions, resource names, rooms, preserved source, or a reference build.
7. Patch the smallest compatible behavior.
8. Rebuild or ask the user for a new compile/runtime log.
9. Update the project dev log or migration notes when the fix changes migration behavior.

## Compile Fixes

For common imported-code failures, read `references/gm-legacy-patterns.md`.

Typical fixes include:

- Rename scripts that shadow built-ins, such as a user script named `random`.
- Rename scripts with spaces so generated calls compile as single identifiers.
- Replace broken Drag and Drop actions with equivalent GML when the original behavior is clear.
- Audit for legacy Drag and Drop actions that import silently as `Unknown Action` in GMS1.4 before trusting a clean import. Search object XML for known legacy function names and suspicious empty action functions; treat `OBSOLETE:`/`LEGACY:` strings only as manual cleanup notes when a maintainer added them. See `references/gm-legacy-patterns.md` for detection commands and replacement choices.
- For legacy DnD Sleep imports (action id `302`) that open as unknown/obsolete actions in GMS1.4, convert them to `action_execute_script` (`id 601`) calling a dedicated bridge script with the same first two arguments (`duration_ms`, legacy redraw flag). Use a project-appropriate traceable name, for example `sc_legacy_sleep`, and document all affected objects.
- Treat legacy sleep bridge scripts as interim compatibility only. Final target (modern GameMaker phase) should be non-blocking timed actions, such as a wait-for-seconds/steps queue with callbacks. If the repository names a reference project, inspect it for architecture patterns but do not copy systems blindly.
- Do not keep generated compatibility scripts longer than necessary. Once call sites are understood, replace wrappers such as `action_another_room` and `action_change_object` with native modern calls like `room_goto` and `instance_change`, then delete the compatibility script from the active project.
- Add temporary compatibility scripts only when they unblock compile and are clearly documented.
- Remove or replace legacy save/highscore APIs when the target platform does not support them. For HTML5, old save/load/highscore calls usually need browser-safe storage, online services, or removal from the migrated flow.
- Treat the old `Show the highscore table` action as unsupported in GMS1.4/HTML5 even when the importer gives no warning. Replace it with project-owned UI/storage, or remove it from the migrated flow if scores are nonessential.
- Replace blank numeric imported arguments with a conservative `0` only when the intended blank value means no offset/speed.
- When GMS1.4 reports wrong argument counts for imported `action_move` or `action_create_object`, first inspect the action XML for blank numeric argument slots. A blank `<string></string>` in a numeric argument often means the old editor intended `0`; replacing only that blank with `0` may restore compilation without replacing the action.
- Do not introduce compatibility bridge scripts for imported `action_move` or `action_create_object` unless the native action still fails after argument cleanup and the intended behavior is fully verified. GMS1.4 can emit different Execute Script arities for similar-looking converted blocks, so a bridge can create arity regressions that are harder to debug than the original import error.
- For resource name collisions, verify the actual asset before changing references. Project-tree folder names can be misleading after import.
- When a collision requires a rename, first follow the active repository's naming convention. If none exists, use the default convention from `references/gm-legacy-patterns.md`: two-character resource prefix plus underscore, such as `sp_`, `ob_`, or `rm_`.
- Treat GM5 group paths as non-unique metadata after import. Same-name resources from different GM5 groups can collapse into one GMS1 resource identity.
- If baseline shows same-name resources with different behavior (for example pickup object vs cast projectile), split them into explicit unique GMS1 resource names first, then rewire call sites by behavior path.
- If many same-name resources are known before import, especially from GM4/GM5 groups that allowed duplicates, consider renaming the source project resources before the GMS1.4 import and then doing a clean reimport. This can avoid widespread asset-tree corruption, stale project registrations, and wrong-resource bindings that are much more expensive to identify manually after import.
- When a clean reimport after source-side renaming eliminates missing-resource dialogs and collision-driven runtime inconsistencies, prefer that baseline over continuing manual relink surgery in the corrupted import. Preserve the pre-reimport project or notes as evidence, then reapply only the small compile fixes that are still reproducible in the new import.
- After large rename batches, re-open in GMS1.4 and treat missing-resource startup dialogs as a relinking checklist. Prioritize stale Execute Script arguments and resource tags in object XML before doing broader runtime debugging.
- When fixing player action, spell, or sprite-cast branches in imported object XML, validate the affected input path immediately in runtime after each small edit. Compile-success alone is not enough.
- If duplicate texture-page names appear (for example duplicate `*.tpe` names), inspect the active `.project.gmx` file for repeated `<sprite>...</sprite>` entries across multiple folders and remove only duplicated project-tree listings, not real sprite files.
- For character-specific sprite isolation, do not use broad project-wide text replacement. Apply scoped edits per object/resource and verify unrelated groups are unchanged.
- For meaningful semantic/identity renames, update the active repository's historical rename log or migration notes in the same batch so old/new references remain traceable during migration.
- Always run two separate audits after rename passes: (1) tree structure audit against the baseline import and (2) sprite-content audit (frame references, dimensions, and optional hash checks) to catch wrong-image reuse.
- After replacing legacy `OLD: Change sprite` actions, scan object XML for unresolved placeholders (`<sprite>-100</sprite>`, `<object>-100</object>`, `<undefined>`). Resolve each by branch intent, such as directional state mappings, before trusting compile success.
- Apply-target hardening:
  - Treat `whoName`/`useapplyto` as gameplay semantics, not cleanup formatting.
  - Do not batch-convert `<whoName>&lt;undefined&gt;</whoName>` to `self`.
  - In Destroy/Collision flows (especially `action_kill_object` and sprite/object setters), require legacy-behavior verification before changing targets.
  - When GM5 reference exists, compare target ownership there before finalizing.
- For every compatibility script, require a non-ambiguous header comment that states:
  - original replaced action/function (include action id when known),
  - argument contract and units,
  - known current call sites,
  - temporary vs final intent.
- Avoid formatting churn in GMX/XML:
  - Do not run broad normalization/reformatting passes while fixing logic.
  - Apply surgical edits to the exact nodes involved in the bug/fix.
  - Before closing a batch, inspect unstaged diffs and classify each file as semantic change vs autosave formatting change.
  - Exclude whitespace/tag-shape/line-ending-only changes from the fix batch unless the user explicitly requests normalization.

## Browser Runtime Validation

For HTML5/browser runtime work, read `references/html5-runtime-validation.md`.

Prioritize:

- title/menu flow
- player movement and collision
- viewport/camera behavior in rooms with multiple views or HUD viewports
- character sprite correctness
- room transitions
- cutscenes and wait/pause logic
- drawing/HUD visibility
- fullscreen, resize, and canvas behavior
- audio playback and looping
- audio-ended flows and fallback timeouts when progression waits for playback completion
- combat, magic, enemy behavior
- ending/game-over flows

## MIDI Music Migration

For legacy GM4/GM5/GMS1.4 music that uses `.mid` or `.midi` files, especially for HTML5/web export, read `references/audio-midi-to-mp3.md`.

Migration rules:

- Treat source MIDI files as preserved assets.
- Render MIDI to browser-compatible audio with FluidSynth, FFmpeg, and a documented SoundFont.
- If the selected SoundFont is missing, use the bundled fetch script before asking the user to provide one.
- Stage generated MP3/OGG/WAV files outside the active `.gmx` project tree until the import/relink step is intentional.
- In GMS1.4 projects, inspect `sound/*.sound.gmx` to identify registered MIDI resources instead of blindly converting every loose file in `sound/audio/`.
- Document the SoundFont source/license/checksum and note that MIDI rendering can differ from the original system MIDI playback.
- For modern `.yyp` projects, relink rendered audio through GameMaker/ResourceTool metadata, not by only copying files. With `gm-cli`, use ResourceTool `SOUND SETFILE NAME=<sound> PATH=<audio-file>`, then inspect the resource folder because the old linked file may remain on disk.
- After importing converted audio into GameMaker, compile the target platform, then validate music playback, looping, room transitions, and browser audio unlock behavior.

## Dev Log Notes

Record meaningful migration decisions with:

- what broke
- where it broke: object, event, script, room, or imported action
- what original behavior appeared to be
- what changed
- whether the fix is temporary or final
- follow-up validation needed

## Sensitive Resource Families

Preserve all resources for player powers, playable characters, major NPCs, enemies, bosses, menu systems, story/cutscene controllers, rooms, backgrounds, sounds, and endings unless the user explicitly approves removal.

When cleaning duplicate resource names, keep every distinct gameplay resource present until its behavior and references have been validated. Same-name resources may represent different families, such as pickup vs projectile, menu vs room controller, or character-specific movement sprites.
