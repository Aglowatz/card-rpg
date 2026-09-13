## Common interface for anything that plays an enemy's turn. BattleState
## calls take_turn() during that combatant's main phases without needing
## to know whether it's deck-playing or scripted-intent -- see
## DeckPlayingController and ScriptedIntentController.
class_name EnemyController
extends RefCounted

func take_turn(_battle: BattleState, _combatant: Combatant) -> void:
	push_error("EnemyController.take_turn() not implemented")
