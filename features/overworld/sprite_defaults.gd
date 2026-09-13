## The one project-wide pixel_size constant, per the 2.5D technical law in
## CLAUDE.md: every Sprite3D/AnimatedSprite3D in the game shares this value.
## Never set pixel_size per-sprite.
class_name SpriteDefaults
extends RefCounted

## 32 texture pixels per world meter.
const PIXEL_SIZE: float = 1.0 / 32.0

## Applies the standard billboard configuration to a world sprite: fixed-Y
## billboarding, discard-based alpha (for correct per-pixel depth sorting),
## unshaded, single-sided, nearest-filtered, and a feet-anchored pivot.
## Typed to Sprite3D rather than the SpriteBase3D base class because
## `texture` is not declared on SpriteBase3D (AnimatedSprite3D uses
## sprite_frames instead).
static func configure(sprite: Sprite3D, texture: Texture2D) -> void:
	sprite.texture = texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	sprite.double_sided = false
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	sprite.pixel_size = PIXEL_SIZE
	sprite.centered = false
	if texture:
		sprite.offset = Vector2(-texture.get_width() / 2.0, 0.0)
