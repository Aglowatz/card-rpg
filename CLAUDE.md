# Cloudsea Isles — Project Constitution

This is the source of truth for what this game is and how it gets built. If code and this
document disagree, that's a bug in one of them — fix the code, or bring the disagreement back
here and update this file. Working title: "Cloudsea Isles." See "On the title" at the bottom for
how to change it.

## What this game is

A single-player, card-based RPG meant to take roughly 15 hours to complete, built solo in Godot
4 with GDScript, using Claude Code as the primary development tool.

Three games shaped this design, each for a specific reason:

- **Magic the Gathering: Shandalar** — the overworld. A world you walk around in, talk to people
  in, and fight card-based duels inside. Shandalar is the proof that a card game and an RPG
  overworld can share one game without either feeling bolted on.
- **Hex: Shards of Fate, PvE mode** — a campaign built entirely around a card game, with
  progression, itemization, and encounter variety layered on top of the core card rules, rather
  than the card game being a minigame inside a bigger RPG.
- **Inscryption** — the *feel* of playing a single card. Weight, tactility, a sense that each card
  has a specific, sometimes surprising trick to it, rather than being a generic stat stick.

This is **not a roguelite.** Progress is permanent. Levels, items, and equipment persist between
sessions and between dungeons. A run does not end in death and restart from zero; it ends in
victory, and death is a setback within a dungeon, not a reset of the campaign. If a future
feature proposal would reset player progress on failure, it does not belong in this game.

JRPG systems are load-bearing, not decoration: character levels gained through experience,
a real item and equipment economy, and dungeons that are places, not just fights.

## Acceptance criteria

These are the conditions the finished game must satisfy. Treat each as testable, not aspirational.

- Total playtime for one campaign completion is approximately 15 hours.
- Dungeons take 30 to 45 minutes each and contain multiple encounters, meaning several distinct
  card-game fights per dungeon, not one boss fight. Dungeons also contain at least one minigame
  distinct from the core card combat, and something to explore — a secret, an optional room, an
  item cache, a piece of lore.
- There is an overworld the player directly controls their character in: walking around, talking
  to vendors, talking to NPCs, and choosing where to go next. The overworld is not a menu; it is
  a place.
- The player's character has levels, gains experience, and grows in capability outside of what
  their deck alone provides. Items and equipment exist and matter — they are not purely cosmetic.
- The game is highly replayable. This means real decision points that change how a playthrough
  goes: multiple viable deck archetypes, build-defining item and equipment choices, and enough
  card pool depth that two playthroughs can look meaningfully different. Replayability comes from
  breadth of viable choice, not from randomized roguelite runs.
- The game has one consistent, deliberate art style applied everywhere — cards, UI, overworld,
  dungeons — and that style is documented well enough that new art fits into it without
  guesswork. See "Art law" below for how that consistency is enforced technically, not just
  aspirationally.

## Architectural law

**`src/core/` may not depend on the scene tree.** No `Node`, no `Texture2D`, no `await`. Code in
`src/core/` uses only `Resource` and `RefCounted`. This is the single rule everything else in this
section depends on, and it is not a style preference — it is what makes the following possible:

- Combat logic is runnable and assertable from the command line with no window, no rendering, and
  no scene instantiation.
- Balancing hundreds of cards solo is only tractable by simulation. A headless core is what makes
  it possible to run thousands of AI-vs-AI matches overnight to find degenerate strategies or dead
  cards, rather than hand-testing every matchup.
- Presentation (`features/`) can change completely — new animations, a new UI, a new platform —
  without touching the rules of the game.

Communicate down the scene tree via direct calls on children; communicate up via signals. A node
should not reach for its parent or grandparent. Anything that would need to should probably be
extracted into its own scene, or the data it needs should be injected via `@export`.

## Card data law

`CardData` is a `Resource`, saved as `.tres`, and it is an immutable template — the definition of
what a card is, not a specific copy of it in play. `CardInstance` is a `RefCounted` object that
wraps a `CardData` and holds everything that changes while the game runs: damage taken, temporary
counters, buffs, current zone.

Never mutate a loaded `CardData` in place. `load()` on the same path returns the exact same
object every time Godot's resource cache is warm, so mutating one card's `.tres` at runtime would
silently corrupt every copy of that card anywhere else it's referenced — in the player's deck, in
an enemy's deck, in a shop listing, all at once. If a card needs modification, that modification
lives on the `CardInstance`, never on the `CardData` it wraps.

Every custom `Resource` subclass needs a parameterless `_init()`. Without one, it fails to load
correctly in the Godot Inspector, which is where most `.tres` authoring and debugging happens.

## Effect law

Card abilities are represented as data, not as one script written per card. A small set of
composable `Effect` and `Selector` primitives — on the order of 40 total — recombine to produce
hundreds of distinct cards. A card that deals damage to a target and a card that deals damage to
all enemies share the same `DealDamage` effect and differ only in which `Selector` they're paired
with.

Static, continuous effects — "your creatures get +1/+0," for example — are never written back
onto the cards they affect. They are recomputed as layered modifiers whenever a stat is queried.
Writing a static buff's value directly onto a card is exactly how the classic "buff applied twice,
never correctly removed" bug class happens, and it is the reason this rule exists.

Because this is single-player with no instant-speed opponent responding to your plays, the
MTG-style priority-passing loop does not apply here and should not be built. When the player takes
an action, the effect stack resolves automatically to empty; the game only pauses for the player
when an effect specifically requires a choice from them, such as picking a target.

## Art law — the swappability rule

The plan for card art is: **placeholder now, public-domain curation as the first real pass,
AI-generated card art later** — and the pipeline must be built from day one so that final step is
a data change, never a code or architecture change.

Concretely, that means: card art is always referenced by card ID resolved through a fixed path
convention (for example, a card with id `spark_wisp` looks for its art at a predictable path
derived from that ID), never hardcoded per-card in a script or scene. Visual unification —
matching color grading, a shared paper-grain or parchment overlay, a consistent vignette — happens
in one runtime shader applied uniformly, not baked into each image file individually. This is what
lets a visually inconsistent set of placeholder or public-domain source images still read as one
deliberate art direction, and it's what lets a wholesale swap to AI-generated art later touch only
`assets/art/cards/` and nothing else.

Until real art exists, cards render with procedural `StyleBoxFlat` panels, borders, and text. No
external image asset is required for this to look intentional rather than broken — see the hello
world in `features/card/` for the reference implementation.

## Save law

Saves are JSON, never `Resource`/`.tres`. A `.tres` file can embed a script, so loading one from
disk can execute arbitrary code — that is a real vulnerability for any save file that might ever
be shared, moved between machines, or restored from an untrusted backup, and there is no reason to
accept that risk for a feature that JSON handles just as well.

A save stores card IDs and quantities, never card objects, and resolves those IDs against the
current card database on load. This is also what lets an old save survive a balance patch instead
of shipping with stale card definitions baked in.

Every save file carries a `save_version` field and has an explicit migration path from each prior
version. Writes are atomic: write to a temporary file, then rename over the real save file, so a
crash mid-write cannot destroy an in-progress campaign.

## Style

Typed GDScript everywhere — this is enforced at the engine level, not just requested. In
`project.godot`, `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access`, and
`unsafe_cast` are all set to error, not warning. `godot --headless --path . --check-only --script
<file>` is a real type-checker as a result; run it, don't just write code and hope.

Follow the official GDScript style guide's file-ordering convention (signals, enums, constants,
exports, public vars, private vars, `@onready` vars, `_init`, `_ready`, other virtuals, public
methods, private methods). Tabs for indentation. Trailing commas in multiline arrays, dictionaries,
and enums — they produce much smaller, cleaner diffs, which matters more here than usual because a
meaningful fraction of this codebase's diffs are AI-generated patches.

## Workflow rules

- Run `make import` after creating or modifying any `.tscn`, `.tres`, or asset, before doing
  anything else with it. Without a populated `.godot/` directory, `class_name` scripts are not
  registered, and both type-checking and test bootstrap fail in ways that look unrelated to the
  actual cause.
- Run `make test` before calling any task finished. A change that isn't covered by the existing
  suite and clearly should be needs a test added alongside it, not after.
- Never hand-edit anything inside `.godot/` or `addons/`. `.godot/` is regenerated by the engine;
  `addons/` holds third-party code (GUT) that should be updated by re-pulling it, not patched in
  place.
- Before committing a new binary file — art, audio, a font — check that `.gitattributes` actually
  routes its extension through Git LFS. If it's a new extension, add it there first.
- `project.godot` gets rewritten and reordered by the Godot editor itself. Don't rely on comments
  placed inside it surviving an editor save.

## Lore bible seed

Carried forward from the archived HTML prototype (`archive/bloomdrift-prototype/`), which was a
different game (a 3D platformer) but established a setting and voice worth keeping:

The islands drift above a "Cloud-Sea." They used to be a single hill, until — as the story is told
in-world — a dandelion sneezed so hard it broke clean apart, and the pieces have been drifting
ever since. The tone is whimsical, punny, and gently absurd without undercutting real stakes.
Established NPC voices to build from: a sky-cart shopkeep with a rambling, lonely warmth to them; a
barber who never asks questions; a competitive racer type who's a good sport about losing.

The prototype's palette is the starting point for the UI's color language: deep purple panels
around `#2c2440`, gold accents around `#ffd23f`. Treat these as a starting anchor for the shader
and theme work described in "Art law," not as a hard requirement — the final palette is a Phase 10
decision once faction identity exists.

## On the title

"Cloudsea Isles" is a working title, not a final decision. If it changes, update
`config/name` in `project.godot`, the title in this file's first line, and the window title
string in `features/ui/main.tscn` — that's the entire surface area. Nothing else in the codebase
should ever hardcode the game's name.
