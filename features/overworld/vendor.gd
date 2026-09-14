## A placeholder card vendor: no physical body (the player walks up to it
## freely, never bumps into it), just a visual and an interact zone. Real
## buying/selling is a later phase -- for now, interacting just opens the
## same card inventory browser the "I" key opens, per the reusable
## inventory hard requirement in CLAUDE.md.
class_name Vendor
extends Node3D

@export var sprite_id: StringName = &"card_vendor"
@export var display_name: String = "Card Vendor"

@onready var _sprite: Sprite3D = %Sprite3D

func _ready() -> void:
	add_to_group("vendor")
	SpriteDefaults.configure(_sprite, ArtRegistry.sprite(sprite_id))
