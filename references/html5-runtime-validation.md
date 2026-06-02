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
- looped music restarts correctly after room changes
- one-shot effects do not loop accidentally
- legacy MIDI music has been rendered to a browser-compatible format with a documented SoundFont
- imported converted audio plays on target browser
- converted music loops and transitions acceptably compared with original behavior

### Input

Validate keyboard constants and browser focus behavior. Check that menu/pause controls do not depend on blocking input waits.

## Smoke Test Checklist

- Game starts without runtime errors.
- Title/menu flow works.
- Player movement works.
- Collision does not trap or drift the player.
- Room transitions work.
- HUD and draw layers are visible.
- Music and effects play acceptably.
- Magic/combat works at a basic level.
- Enemies move, collide, and die as expected.
- Cutscenes advance without blocking the browser.
- Game over and ending flows are reachable.
