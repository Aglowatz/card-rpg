## A single mutable copy of a card in play.
##
## Wraps an immutable CardData template with the state that changes as the
## game runs: damage taken, temporary counters, and so on. Never write
## mutable state onto the CardData itself — see card_data.gd for why.
class_name CardInstance
extends RefCounted

var data: CardData
var damage_taken: int = 0

func _init(p_data: CardData) -> void:
	data = p_data

func current_toughness() -> int:
	return data.toughness - damage_taken

func is_destroyed() -> bool:
	return current_toughness() <= 0
