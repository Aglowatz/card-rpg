# Cloudsea Isles — Development Roadmap

This is the phase-by-phase plan for the whole project, from empty repo to shippable campaign. Each
phase lists its goal, what it delivers, and how to tell it's actually done. Phases are meant to be
done roughly in order, but later phases can start early where they don't depend on something
earlier being finished — content authoring, for instance, doesn't have to wait for the overworld.

See `CLAUDE.md` for the constitution these phases are building toward — the acceptance criteria
there are the ultimate target; the criteria listed per phase here are checkpoints along the way.

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

## Phase 3 — Core combat engine (headless)

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

## Phase 4 — Battle presentation

Put a face on the Phase 3 engine.

Delivers: the hand and battlefield scenes, drag-to-play card interaction, an event-queue animation
layer that consumes the stream of events the core engine emits and animates them without ever
blocking or feeding decisions back into game logic, and a real `UIChoiceProvider` implementation
alongside the test one from Phase 3.

Done when: a full duel is playable start to finish with the mouse, animations read clearly enough
to follow what happened without reading a log, and the Phase 3 headless tests still pass unchanged
— presentation must not have required touching core rules.

## Phase 5 — Content pipeline

Make authoring hundreds of cards fast rather than the bottleneck it would otherwise become.

Delivers: a spreadsheet-or-JSON authoring format, an `@tool` script that bakes that source into
`.tres` `CardData` resources in `data/cards/`, the `CardDB` autoload that indexes and loads them,
and validator tooling that catches malformed or duplicate card definitions before they cause a
runtime error.

Done when: adding a new card is "add a row, rerun the bake script," not "hand-write a `.tres`
file," and a deliberately malformed card entry is caught by the validator rather than silently
producing a broken card in-game.

## Phase 6 — Overworld

Build the place the player lives in between fights.

Delivers: player-controlled movement, the `SceneManager` autoload with named spawn points for
scene transitions, a persistent `WorldState` (flags for opened chests, cleared areas, talked-to
NPCs) that survives scene changes, functioning vendor and dialogue interactions, using the
prototype's shop state model (`locked -> buy -> unaffordable -> owned`) as the vendor pattern.

Done when: the player can walk from one map to another, talk to at least one vendor and buy
something, talk to at least one NPC with dialogue, and world state persists correctly across a
scene transition and a save/reload.

## Phase 7 — JRPG progression

Layer the RPG half of "card RPG" on top of the card game.

Delivers: character levels and experience, an inventory system, equipment slots that produce a
real gameplay effect (not cosmetic-only), and the economy connecting overworld vendors to that
inventory and equipment.

Done when: playing through combat encounters produces experience, leveling up produces a
noticeable capability change, and at least one piece of equipment measurably changes how a duel
plays out.

## Phase 8 — Dungeons

Assemble everything so far into the actual 30–45 minute content unit the constitution requires.

Delivers: a multi-encounter dungeon structure (several card duels per dungeon, not one), an
exploration layer with at least one secret or optional area per dungeon, loot tied to dungeon
completion, and a minigame framework distinct from core card combat with at least one real
minigame implemented.

Done when: one complete dungeon can be played start to finish, runs 30 to 45 minutes in practice
(not just on paper), and contains combat, exploration, and a minigame as the constitution
requires — this is the phase where "dungeons should take approximately 30-45 minutes" gets
verified against a stopwatch, not assumed.

## Phase 9 — Campaign content and balance

Build out the full 15-hour campaign and make it actually balanced.

Delivers: the full card pool (on the order of 200–500 cards), the full set of dungeons and
overworld areas needed to reach 15 hours of campaign length, and an AI-vs-AI simulation harness
built on the headless Phase 3 engine, used to run large batches of automated matches to surface
dead cards, degenerate strategies, and balance outliers before a human ever has to find them by
hand.

Done when: the campaign is completable start to finish at roughly the target length, and the
simulation harness has actually been run and has actually changed at least one card as a result —
not just built and left unused.

## Phase 10 — Art pass

Replace placeholders with the real, unified visual identity the constitution requires.

Delivers: curated public-domain source art for the first real pass (with a provenance record per
image — source, rights statement, date accessed — kept for every asset used), the unifying shader
pipeline (duotone by faction, paper grain, vignette) applied globally, and the swap path to
AI-generated card art exercised and confirmed to require no code changes, per the art law in
`CLAUDE.md`.

Done when: every card, UI element, and location uses the same visual language, a new piece of art
can be added by dropping a file into `assets/art/` and reimporting with no script changes, and the
provenance record for the public-domain pass is complete enough to defend if ever challenged.

## Phase 11 — Audio, polish, and export

Ship it.

Delivers: sound effects and music, save/load hardening (versioned migrations actually exercised
against an old save format, atomic writes verified against a simulated crash), performance pass,
and export configuration for the target platform(s).

Done when: a save from an early build still loads correctly in the shipping build via its
migration path, and an exported build runs standalone outside the editor with no missing-asset or
missing-autoload errors.
