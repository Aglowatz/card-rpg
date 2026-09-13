## Anything that can be the target of damage: a creature (CardInstance) or
## a player's face (Combatant). Effects target this common type rather than
## CardInstance directly, so a spell can hit either through one typed
## interface -- a Variant-typed target would trip the project's
## unsafe_method_access strict-typing gate.
class_name Damageable
extends RefCounted

func take_damage(_amount: int) -> void:
	push_error("Damageable.take_damage() not implemented")

func is_defeated() -> bool:
	push_error("Damageable.is_defeated() not implemented")
	return false
