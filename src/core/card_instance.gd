## A single mutable copy of a card in play.
##
## Wraps an immutable CardData template with the state that changes as the
## game runs: damage taken, tapped/summoning-sick status, and so on. Never
## write mutable state onto the CardData itself — see card_data.gd for why.
class_name CardInstance
extends Damageable

var data: CardData
var damage_taken: int = 0
var tapped: bool = false
var summoning_sick: bool = true

func _init(p_data: CardData) -> void:
	data = p_data

func current_toughness() -> int:
	return data.toughness - damage_taken

func is_destroyed() -> bool:
	return current_toughness() <= 0

func take_damage(amount: int) -> void:
	damage_taken += amount

func is_defeated() -> bool:
	return is_destroyed()
