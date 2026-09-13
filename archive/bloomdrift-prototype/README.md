# Bloomdrift Isles (archived prototype)

This is the original single-file HTML/three.js prototype that predates the Godot rewrite.
Despite the project's early working name ("card RPG"), this prototype is not a card game — it
is a 3D platformer titled "Bloomdrift Isles," with tank-style movement, ice-cream collectibles, a
freeze-the-critters objective, a barbershop, and a three-lap race minigame.

It is kept here, untouched, for reference: a `.gdignore` file sits next to it so Godot's importer
skips this folder entirely, and it plays no part in the actual game build.

What was carried forward from it into the Cloudsea Isles constitution (see the root
`CLAUDE.md`):

- The setting: floating islands drifting above a "Cloud-Sea," said to have been one hill until a
  dandelion sneezed hard enough to break it apart.
- The established NPC voice: Buncle Pip (sky-cart shopkeep), Coco (barber), Turbo Tam (racer).
- The vendor/shop state model: `{label, description, cost, state, lockedReason}` with a
  `locked -> buy -> unaffordable -> owned` progression and gated upgrade chains.
- A 70-entry color palette, anchored on deep purple panels (`#2c2440`) with gold accents
  (`#ffd23f`).

To view it, open `index.html` directly in a browser. It has no build step and no dependencies
beyond what's bundled inline.
