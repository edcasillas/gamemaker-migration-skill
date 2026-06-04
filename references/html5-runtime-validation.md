# HTML5 Runtime Validation

This reference covers browser validation after a legacy Game Maker project compiles.

## Validation Loop

1. Reproduce the bug in the smallest path.
2. Identify room, object, event, script, and action.
3. Compare against original source or reference build when available.
4. Patch minimally.
5. Rebuild and replay the affected path.
6. Log the decision and follow-up.

## High-Risk Legacy Behaviors

### Blocking waits

Old projects may use:

```gml
screen_refresh();
screen_redraw();
keyboard_wait();
```

or DnD sleep actions.

Do not restore these with blocking loops for HTML5. Use:

- Step events
- Draw events
- Alarms
- state variables
- cutscene controllers
- room transition controllers

If old timing depended on audio duration or an audio-ended event, add a fallback timeout and a no-sound path. Browser audio can fail to start or can be blocked until user interaction.

### Pause screens

Prefer a pause state:

```gml
global.paused = true;
```

Then gate Step behavior and draw pause UI in Draw/Draw GUI. Avoid waiting inside a script until a key is pressed.

### Cutscenes

Replace "wait, draw, wait, advance" scripts with:

- `cutscene_state`
- `cutscene_timer`
- per-step input checks
- Draw event rendering
- Alarm or frame-count transitions

### Audio

Validate:

- browser starts audio only after acceptable user interaction
- `audio_play_sound` returning no valid handle does not deadlock a menu, intro, or cutscene
- audio-ended events advance only the intended flow and clear any fallback alarms/timers
- looped music restarts correctly after room changes
- one-shot effects do not loop accidentally
- legacy MIDI music has been rendered to a browser-compatible format with a documented SoundFont
- imported converted audio plays on target browser
- converted music loops and transitions acceptably compared with original behavior

### Console and file probes

Chrome console 404s in generated GameMaker HTML5 code are not always broken
assets. On HTML5, `file_exists()` can check browser storage first and then issue
a visible `HEAD` request for `html5game/<filename>` before returning false.

When triaging console noise:

- confirm whether the page is an IDE runner URL such as
  `http://localhost:<port>/` or an exported build folder
- map the generated JavaScript source line back to GML calls such as
  `file_exists`, `file_text_open_read`, `ds_map_secure_load`, or CSV loading
- preserve intended dev fallbacks, especially build-number fallbacks, instead
  of adding placeholder files that can become stale
- do not assume a GameMaker IDE HTML5 run uses the DevBuild config; config or
  macro state can differ from the fact that the runner is local
- treat first-run settings-file 404s separately from missing asset 404s

### Input

Validate keyboard constants and browser focus behavior. Check that menu/pause controls do not depend on blocking input waits.

### Views, fullscreen, and resize

Old rooms can depend on multiple active views, fixed room surfaces, or GUI drawn in room coordinates. HTML5 can expose problems that are invisible in the desktop runner.

Validate:

- combined visible viewport sizes fit the game surface or application surface
- HUD/status views do not squeeze or crop the main play view
- Draw GUI content still appears in fullscreen and after browser resize
- fullscreen support is disabled or fixed when GUI scaling cannot be trusted
- resize callbacks, if used, bridge JavaScript events into GML through explicit script names

### Mobile browser policy

If mobile play is unsupported, fail intentionally instead of letting the game run broken.

Validate:

- mobile detection happens before gameplay timers, analytics, or audio-dependent flows create inconsistent state
- the disabled-canvas or unsupported-device message is visible
- clearing browser timers or hiding the canvas does not prevent required analytics or logging from completing unless that tradeoff is intentional

## Smoke Test Checklist

- Game starts without runtime errors.
- Title/menu flow works.
- Player movement works.
- Collision does not trap or drift the player.
- Room transitions work.
- HUD and draw layers are visible.
- Fullscreen/resize behavior does not corrupt GUI placement.
- Unsupported mobile behavior is explicit, if mobile is out of scope.
- Music and effects play acceptably.
- Magic/combat works at a basic level.
- Enemies move, collide, and die as expected.
- Cutscenes advance without blocking the browser.
- Game over and ending flows are reachable.
