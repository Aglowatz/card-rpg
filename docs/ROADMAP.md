# Cloudsea Isles — Development Roadmap

This is the phase-by-phase plan for the whole project, from empty repo to shippable campaign. Each
phase lists its goal, what it delivers, and how to tell it's actually done. Phases are meant to be
done roughly in order, but later phases can start early where they don't depend on something
earlier being finished — content authoring, for instance, doesn't have to wait for the overworld.

See `CLAUDE.md` for the constitution these phases are building toward — the hard requirements and
acceptance criteria there are the ultimate target; the criteria listed per phase here are
checkpoints along the way.

## Phase 1 — Workspace and tooling

Set up the engine, the repository, and every piece of tooling the rest of the project depends on.
No game code is written in this phase.

Delivers: Godot 4.7 installed, the repository restructured with Git LFS configured before any
binary asset exists, the `.gitignore`/`.editorconfig`/`project.godot` baseline, strict typing set
to error, GUT installed and wired to run headlessly, a `Makefile` with unambiguous commands, a
GitHub Actions workflow, and this constitution and roadmap written.

Done when: `make import` and `make test` both succeed locally, CI is green, and the strict-typing
gate actually fails a deliberately broken file.

## Phase 2 — Hello world

Prove the whole pipeline connects end to end before building anything real on top of it.

Delivers: a `CardData` Resource class, a handful of hand-authored `.tres` cards, a single
`card.tscn` that renders any of them from procedural `StyleBoxFlat` panels with zero image assets,
a `main.tscn` hand of cards wired through the `EventBus` autoload, one working `Effect` subclass
(`DealDamage`), and a GUT test that resolves that effect with no scene tree involved at all.

Done when: the game runs and shows visually distinct cards with no art files, hovering and
clicking a card is observable through the event bus, and the headless effect test passes.

## Phase 3 — 2.5D overworld, battle trigger, and inventory refinement

Build the game's actual foundation: a real 3D world with a controllable, billboarded character,
an enemy that launches a card battle on contact, and the card view refined from a one-off hand
display into the reusable inventory component the hard requirements call for. The battle screen
this phase produces is a stub — Win/Lose/Flee buttons standing in for a combat engine that doesn't
exist yet — but the transition, state preservation, and inventory reuse around it are real.

Delivers: a `CameraRig` with configurable iso/angled-top-down pitch and yaw over an orthogonal
`Camera3D`; a `CharacterBody3D` player moving on camera-relative input; billboarded `Sprite3D`
visuals for the player and enemies following the 2.5D technical law (`BILLBOARD_FIXED_Y`,
`ALPHA_CUT_DISCARD`, unshaded, one shared `pixel_size`); procedural placeholder sprites with a
swap-by-filename convention matching the card art pipeline; an enemy with a touch-triggered
`Area3D` that starts a battle and a separate interact `Area3D` reserved for future vendors and
NPCs; a persistent `GameRoot` that freezes and hides the overworld rather than reloading it,
fades between states, and restores the overworld exactly as it was; a `CardBrowser` master-detail
component (list + focus-driven detail preview, keyboard/gamepad navigable) used both as a
full-screen overworld inventory and embedded in the battle stub.

Done when: the player moves smoothly through the 3D world, walking into an enemy fades into a
battle screen showing the card inventory component, resolving the stub battle fades back to the
overworld with the player's position and world state untouched, and the identical `CardBrowser`
scene renders correctly in both the full-screen and embedded contexts.

## Phase 4 — Core combat engine (headless)

Build the actual rules of the card game, entirely inside `src/core/`, with no UI.

Delivers: card zones (deck, hand, discard, battlefield), the turn and phase state machine, the
full effect stack and its resolution order, the `Selector` targeting system, static/continuous
effect layering, the choice-provider abstraction (so a resolution needing player input can be
answered synchronously by a test double in tests and by real UI in the actual game), and a command
log of every action taken, which doubles as replay support.

Done when: a full card duel — draw, play cards, resolve effects, take damage, win or lose — can be
played entirely from a GUT test script with no window opened, and there's meaningful unit test
coverage of the stack, the state machine, and layered statics specifically, since those are the
three places subtle bugs tend to hide.

## Phase 5 — Battle presentation

Replace the Phase 3 battle stub with the real thing, driven by the Phase 4 engine.

Delivers: the hand and battlefield scenes, drag-to-play card interaction, an event-queue animation
layer that consumes the stream of events the core engine emits and animates them without ever
blocking or feeding decisions back into game logic, a real `UIChoiceProvider` implementation
alongside the test one from Phase 4, and the `BattleRequest`/`BattleResult` contract from Phase 3
now carrying real data (an actual enemy deck in, actual rewards out) instead of stub values.

Done when: a full duel is playable start to finish with the mouse, animations read clearly enough
to follow what happened without reading a log, the Phase 4 headless tests still pass unchanged —
presentation must not have required touching core rules — and the overworld transition built in
Phase 3 now leads into a real fight instead of a Win/Lose/Flee stub.

## Phase 6 — Content pipeline

Make authoring hundreds of cards fast rather than the bottleneck it would otherwise become.

Delivers: a spreadsheet-or-JSON authoring format, an `@tool` script that bakes that source into
`.tres` `CardData` resources in `data/cards/`, the `CardDB` autoload that indexes and loads them,
and validator tooling that catches malformed or duplicate card definitions before they cause a
runtime error.

Done when: adding a new card is "add a row, rerun the bake script," not "hand-write a `.tres`
file," and a deliberately malformed card entry is caught by the validator rather than silently
producing a broken card in-game.

## Phase 7 — Overworld systems

Phase 3 built one map with one movable character. This phase makes the overworld an actual place
with more than one location and things to do in it.

Delivers: a `SceneManager` autoload with named spawn points for moving between maps, a persistent
`WorldState` (flags for opened chests, cleared areas, talked-to NPCs, defeated enemies) that
survives map transitions, functioning vendor and dialogue interactions built on the interact
`Area3D` infrastructure from Phase 3, using the archived prototype's shop state model
(`locked -> buy -> unaffordable -> owned`) as the vendor pattern.

Done when: the player can walk from one map to another through a normal transition (not just the
battle fade), talk to at least one vendor and buy something, talk to at least one NPC with
dialogue, and world state persists correctly across a map transition and a save/reload.

## Phase 8 — JRPG progression

Layer the RPG half of "card RPG" on top of the card game.

Delivers: character levels and experience, an inventory system, equipment slots that produce a
real gameplay effect (not cosmetic-only), and the economy connecting overworld vendors to that
inventory and equipment.

Done when: playing through combat encounters produces experience, leveling up produces a
noticeable capability change, and at least one piece of equipment measurably changes how a duel
plays out.

## Phase 9 — Dungeons

Assemble everything so far into the actual 30–45 minute content unit the constitution requires.

Delivers: a multi-encounter dungeon structure (several card duels per dungeon, not one), an
exploration layer with at least one secret or optional area per dungeon, loot tied to dungeon
completion, and a minigame framework distinct from core card combat with at least one real
minigame implemented.

Done when: one complete dungeon can be played start to finish, runs 30 to 45 minutes in practice
(not just on paper), and contains combat, exploration, and a minigame as the constitution
requires — this is the phase where "dungeons should take approximately 30-45 minutes" gets
verified against a stopwatch, not assumed.

## Phase 10 — Campaign content and balance

Build out the full 15-hour campaign and make it actually balanced.

Delivers: the full card pool (on the order of 200–500 cards), the full set of dungeons and
overworld areas needed to reach 15 hours of campaign length, and an AI-vs-AI simulation harness
built on the headless Phase 4 engine, used to run large batches of automated matches to surface
dead cards, degenerate strategies, and balance outliers before a human ever has to find them by
hand.

Done when: the campaign is completable start to finish at roughly the target length, and the
simulation harness has actually been run and has actually changed at least one card as a result —
not just built and left unused.

## Phase 11 — Art pass

Replace placeholders — both card art and the procedural world sprites from Phase 3 — with the
real, unified visual identity the constitution requires.

Delivers: curated public-domain source art for the first real pass (with a provenance record per
image — source, rights statement, date accessed — kept for every asset used), the unifying shader
pipeline (duotone by faction, paper grain, vignette) applied globally, and the swap path to
AI-generated card art exercised and confirmed to require no code changes, per the art law in
`CLAUDE.md`.

Done when: every card, UI element, and location uses the same visual language, a new piece of art
can be added by dropping a file into `assets/art/` and reimporting with no script changes, and the
provenance record for the public-domain pass is complete enough to defend if ever challenged.

## Phase 12 — Audio, polish, and export

Ship it.

Delivers: sound effects and music, save/load hardening (versioned migrations actually exercised
against an old save format, atomic writes verified against a simulated crash), performance pass,
and export configuration for the target platform(s).

Done when: a save from an early build still loads correctly in the shipping build via its
migration path, and an exported build runs standalone outside the editor with no missing-asset or
missing-autoload errors.
