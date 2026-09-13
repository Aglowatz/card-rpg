## The immutable template for a card, authored as a .tres Resource.
##
## CardData never holds mutable per-copy state (current damage, temporary
## buffs, etc.) — that lives on CardInstance instead. Godot caches loaded
## resources, so load("res://data/cards/x.tres") always returns the SAME
## object; mutating a CardData in place would corrupt every copy of that
## card at once.
##
## Custom Resources need a parameterless _init() or they fail to load in
## the Inspector.
class_name CardData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var rules_text: String = ""
@export var cost: int = 0
@export var power: int = 0
@export var toughness: int = 1
@export var effects: Array[Effect] = []

func _init() -> void:
	pass
