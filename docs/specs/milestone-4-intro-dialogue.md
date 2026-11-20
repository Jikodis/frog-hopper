# Spec — Milestone 4: Intro + dialogue

_Created: 2026-11-19 · Status: approved 2026-11-19 (placeholder story lines, house door leads to the bedroom, no skip key until save exists)_

## Goal

The game opens in your **bedroom**, not the town. A dialogue box shows a few lines of
story, one at a time; you press a key to go to the next line. When the story ends you can
walk, and the bedroom door takes you out into the town in front of your house. The dialogue
box is reusable: the shopkeeper in Milestone 5 talks through the same box.

## In scope

- A **bedroom** scene that is the new start scene (main scene).
- A reusable **dialogue box**: speaker name, text that types out letter by letter, and a
  "press to continue" hint. It takes a list of lines and emits a signal when the last
  line is done.
- The **intro**: the bedroom plays the story lines on load; the frog can't move until the
  story ends.
- A **story flag** in `Game` (`intro_done`) so the intro plays once per play session.
- The **house door in town leads back to the bedroom** (instead of the generic empty
  room), and the intro does not replay there.
- A new input action, `interact`, for moving to the next line.

## Out of scope (later)

Save/load between play sessions (so the intro replays each time you open the game, until
save exists), character portraits, choices inside dialogue, talking to people in town,
shop dialogue (Milestone 5), furniture in the bedroom (Milestone 6), real art, sound.

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scenes/dialogue_box.tscn` + `scripts/dialogue_box.gd` | `CanvasLayer` | Panel along the bottom of the screen with a `SpeakerLabel`, a `TextLabel` and a `HintLabel` ("Space ▶"). `start(lines: Array)` shows it and plays the lines; `interact` finishes the typing or moves to the next line; after the last line it hides and emits `finished`. Emits `started` when it opens. Tunable `CHARS_PER_SECOND`. |
| `scenes/bedroom.tscn` + `scripts/bedroom.gd` | scene | A small room (placeholder rectangles: floor, bed, window), a `town_player` instance, an exit door (`action = "town"`), and a `DialogueBox` instance. On load, if `Game.intro_done` is false, it locks the frog, plays `INTRO_LINES`, then on `finished` unlocks the frog and sets `Game.intro_done = true`. |

**Modified:**
- `scripts/game.gd`: add `var intro_done := false` (the first story flag).
- `scripts/scene_router.gd`: add `BEDROOM` and `go_to_bedroom()`. `enter_building("House", ...)`
  goes to the bedroom instead of the generic interior. When the frog leaves the bedroom
  for the first time, the town spawn is set in front of the house door
  (`(0, 360) + (0, -60)`) instead of the default spot by the gate.
- `scripts/town_player.gd`: add `var can_move := true`; when false, velocity is zero.
  The bedroom sets it, so the frog never reaches into the dialogue box (and the box
  never reaches into the frog).
- `project.godot`: add the `interact` action (Space, Enter, E); set the **main scene**
  to `bedroom.tscn`.

## The story lines

The lines live in one constant at the top of `bedroom.gd`, so your son can rewrite them
without touching any other code. Each line is a speaker and some text:

```gdscript
const INTRO_LINES := [
    {"speaker": "Dad", "text": "Wake up, sleepyhead! The sun's been up for hours."},
    {"speaker": "Frog", "text": "Five more minutes..."},
    {"speaker": "Dad", "text": "The shops in town are open. If you catch some flies, you can buy something nice."},
    {"speaker": "Frog", "text": "Flies? I'm on it!"},
]
```

These are placeholder lines; the real story is your son's to write.

## How the dialogue box works

1. `start(lines)` saves the lines, shows the panel, emits `started`, and shows line 1.
2. Showing a line sets `TextLabel.text`, sets `visible_ratio` to 0, and grows it in
   `_process` at `CHARS_PER_SECOND`, so the text types out.
3. Pressing `interact` while the text is still typing shows the whole line at once.
   Pressing it again moves to the next line.
4. After the last line, the panel hides and `finished` is emitted.

**Teaching note:** this is the "nodes talk through signals" rule from `AGENTS.md`. The box
doesn't know the bedroom exists; it just says "I'm done." Milestone 5's shop listens to
the same signal.

**Correctness note: Space does two jobs.** Space is both `jump` and `interact`. That's
fine here, because the dialogue box only listens while it is open and the town frog never
reads `jump`. In Milestone 5, if dialogue ever opens inside the platformer level, this
needs a second look.

## Placeholder art

- Bedroom: a floor rectangle, a bed (rectangle), a window (light-blue rectangle), a door
  mat at the bottom (the exit).
- Dialogue box: a dark, slightly see-through panel across the bottom third of the screen,
  white text, the speaker's name in yellow.

## Done = this playtest passes

Press F5 (the bedroom is now the start scene). Confirm:

- [ ] The game opens in the bedroom with the dialogue box showing the first line.
- [ ] Text types out letter by letter; pressing Space (or Enter or E) mid-line shows the
      whole line; pressing again goes to the next line.
- [ ] The frog can't move while the story is showing.
- [ ] After the last line, the box disappears and the frog can walk.
- [ ] Walking into the bedroom door goes to town, in front of the house.
- [ ] Walking into the house door from town goes back to the bedroom, and the story does
      **not** play again.
- [ ] The level and the other four buildings still work as before (Milestone 3 checklist).
- [ ] No transition loop when you spawn next to the house door or the bedroom door.
