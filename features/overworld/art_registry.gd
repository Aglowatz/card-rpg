## Resolves world sprite art by ID: a real file at
## assets/art/sprites/<id>.png if one exists, otherwise a generated
## placeholder. Mirrors the card art swappability rule in CLAUDE.md so
## dropping in real art later requires no code change.
extends Node

const SPRITE_DIR := "res://assets/art/sprites/"

## id -> [pattern, body color, accent color]
const PLACEHOLDERS: Dictionary = {
	&"player": [PlaceholderArt.HUMANOID, Color("4aa3df"), Color("ffe7a0")],
	&"slime_enemy": [PlaceholderArt.BLOB, Color("6fcf6f"), Color("1b3b1b")],
}

var _cache: Dictionary = {}

func sprite(id: StringName) -> Texture2D:
	if _cache.has(id):
		return _cache[id]

	var texture: Texture2D = null
	var path := SPRITE_DIR + String(id) + ".png"
	if ResourceLoader.exists(path):
		texture = load(path)
	elif PLACEHOLDERS.has(id):
		var entry: Array = PLACEHOLDERS[id]
		texture = PlaceholderArt.from_pattern(entry[0], entry[1], entry[2])
		push_warning("ArtRegistry: using placeholder art for '%s' (drop %s to replace)" % [id, path])
	else:
		push_error("ArtRegistry: no art and no placeholder for '%s'" % id)

	_cache[id] = texture
	return texture
