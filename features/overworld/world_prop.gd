## A purely decorative billboarded world object -- a tree, a wall, a
## torch. No collision, no interaction, just a Sprite3D configured per the
## 2.5D technical law.
class_name WorldProp
extends Node3D

@export var texture: Texture2D

@onready var _sprite: Sprite3D = %Sprite3D

func _ready() -> void:
	SpriteDefaults.configure(_sprite, texture)
