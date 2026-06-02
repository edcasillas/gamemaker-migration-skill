# Fantasma Migration Lessons

This reference summarizes reusable lessons found in Fantasma's repository history. Use these as examples of migration evidence to look for in other projects, not as project-specific instructions.

Evidence source: `/Users/edcasillas/DocsNoCloud/GameMakerProjects/Fantasma` git history.

## Timeline Evidence

- `5274bcb` checked in the GameMaker Studio 1.4 import.
- `9df2a07` preserved the original Game Maker 5.3 archive under `_Original/`.
- `b9005a6` imported the project to GMS2 and generated a compatibility report.
- `a2fd64f` marked the last GMS1.4 tweak before the GMS2 migration.

## Phase Matrix

Use this matrix before applying a lesson. Some fixes belong to the import hop, while others only appeared when targeting modern GameMaker or HTML5.

| Migration phase | Problems seen in Fantasma | Reusable fix pattern |
| --- | --- | --- |
| GM4/GM5 source -> preserved baseline | Original `.gmd` and old tooling could be lost or accidentally edited. | Keep original archives, tools, and reference builds outside active migration edits. |
| GM4/GM5 -> GMS1.4 | Imported Drag and Drop actions, obsolete wait/sleep behavior, legacy resource/script structure, MIDI assets, and HTML-incompatible save calls surfaced in the GMS1.4 project. | Work in the imported `.gmx`, inspect object XML/action blocks, preserve visible timing without blocking waits, remove or replace unsupported APIs, and keep source MIDI files for later rendering. |
| GMS1.4 -> modern GameMaker/GMS2 | The GMS2 importer generated compatibility scripts, an import report, converted script/event files, missing audio-group notes, and modernized resource metadata. | Treat the compatibility report as a checklist, keep wrappers only for compile recovery, then replace clear wrapper call sites with native modern GML. |
| Modern GameMaker -> HTML5/browser | Browser runtime exposed unsupported save/highscore behavior, MIDI/audio playback issues, audio-ended deadlocks, view/surface/fullscreen GUI problems, mobile canvas policy, and JS callback requirements. | Validate in browser, convert audio and resource metadata together, add no-audio/timeouts, audit views/fullscreen/resize, and bridge browser events explicitly. |

## Phase Details

### GM4/GM5 source -> preserved baseline

#### Preserve original source separately

Fantasma kept the old `.gmd` and GM5 installer/archive material in `_Original/` while active migration work happened in the imported project. This made it possible to compare intent without rewriting historical source.

Reusable rule: always identify the preservation boundary before editing. Original legacy files are reference artifacts unless the user explicitly asks to change them.

### GM4/GM5 -> GMS1.4

#### Imported DnD and obsolete waits need behavioral validation

The early GMS1.4 project still contained imported Drag and Drop action XML and obsolete sleep strings in player collisions. Earlier fixes replaced sleep behavior with logging placeholders while the project moved toward non-blocking timing.

Reusable rule: do not emulate blocking sleep in HTML5 or modern GameMaker. Preserve the visible delay with alarms, Step state, timed-action managers, or transition controllers, then replay the affected path.

#### Legacy save/highscore calls may not survive web targets

Commit `f94f1b8` removed an imported `action_save_game` call from level progression because save game was not supported on HTML. The built-in highscore flow was also replaced later with project-owned leaderboard UI and service integration.

Reusable rule: audit progression, game-over, and leaderboard paths for legacy storage/UI APIs before browser export. Replace with explicit browser-safe persistence or remove nonessential saves.

#### MIDI assets require an explicit target decision

The GMS1.4 baseline still carried `.mid` music resources. Commit `365efb3` found that MIDI files were not supported in the target GMS/browser path and converted the main-menu music to OGG. Commit `4987748` completed background music conversion.

Reusable rule: preserve source MIDI files during import, but do not assume the next target can play them. Convert and relink deliberately when targeting modern GameMaker or HTML5.

### GMS1.4 -> modern GameMaker/GMS2

#### Import reports are migration checklists

The GMS2 import produced `notes/compatibility_report_171024_225103513/compatibility_report_171024_225103513.txt`. It documented converted scripts, missing conversion strings, missing sound audio groups, game speed, and generated compatibility scripts.

Reusable rule: read the compatibility/import report before guessing. It can identify exact obsolete sleep strings, generated wrapper names, and sound metadata gaps.

#### Generated compatibility scripts should shrink over time

After the GMS2 import, Fantasma contained wrappers such as `action_another_room` and `action_change_object`. Commits `870322c` and `0327972` replaced clear call sites with `room_goto` and `instance_change`, then removed the wrappers.

Reusable rule: keep wrappers for initial compile recovery, then retire them when call-site intent is clear. Search for remaining references before deletion.

### Modern GameMaker -> HTML5/browser

#### MIDI conversion requires sound metadata changes

The sound resource metadata changed extension/data from `.mid` to `.ogg`, and compression/streaming settings changed with it.

Reusable rule: converting audio files is not enough. Update registered sound resources deliberately and validate loop/start behavior in the target runtime.

#### Audio-ended progression needs fallback paths

Commit `9f72c97` moved the intro from an alarm-only delay to an Audio Playback Ended event. Commit `a1b302c` later added a fallback alarm and no-sound handling because the intro could deadlock if the sound did not play.

Reusable rule: when menus, intros, cutscenes, or room transitions wait for audio playback, add a timeout and handle invalid audio handles.

#### HTML5 views and GUI can break differently than desktop

Commit `ae7de19` fixed moving-view rooms in HTML. Commit `1edec75` fixed level 10 scaling because combined view-port heights exceeded the 800x600 game surface. Commit `b12b8c4` disabled fullscreen because GUI did not draw correctly.

Reusable rule: validate rooms with multiple views, HUD/status viewports, fullscreen, and browser resize in the HTML target. Compile success and desktop runner success are not enough.

#### Browser/mobile behavior may need explicit JS bridges

Commits `c0e675c` and `121913f` added mobile detection and disabled the canvas on unsupported mobile browsers. Commit `c51997e` added a JavaScript resize listener that calls back into GML.

Reusable rule: for HTML5, treat JavaScript extensions and GML callbacks as part of the migration surface. Verify function names, generated extension metadata, event dispatch, and browser-side failure modes.

#### Runtime logging helps migrate legacy behavior

Fantasma progressively added JavaScript console logging, room-name logging, in-game notifications, and release exception handling. These changes made browser-only and migration-only failures easier to identify.

Reusable rule: add traceable diagnostics around migrated compatibility paths, especially audio, room transitions, saves, view changes, and browser callbacks.

## Audit Prompts For Other Projects

- Is there a preserved original archive or reference build?
- Which migration phase is active: GM4/GM5 -> GMS1.4, GMS1.4 -> modern, or modern -> HTML5?
- Is there a GMS import or compatibility report? What generated scripts did it add?
- Which compatibility scripts still have live call sites?
- Are any save/load/highscore APIs used on paths that must run in HTML5?
- Are MIDI resources still registered as active sounds?
- Does any flow wait for audio playback completion without fallback?
- Do any rooms use multiple visible views or HUD viewports?
- Does fullscreen or browser resize alter GUI placement?
- Are unsupported mobile browsers handled intentionally?
- Are browser callbacks and extension function names validated in the generated target?
