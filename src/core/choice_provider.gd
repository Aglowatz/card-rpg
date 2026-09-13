## Answers the decisions BattleState can't make on its own: which
## creatures attack, how the defender blocks, and which valid target a
## spell hits. One implementation drives tests and AI-controlled
## combatants (AutoChoiceProvider); a future UI-backed implementation
## drives the human player (Phase 5).
class_name ChoiceProvider
extends RefCounted

func choose_attackers(_available: Array[CardInstance]) -> Array[CardInstance]:
	return []

func choose_blockers(_attackers: Array[CardInstance], _available: Array[CardInstance]) -> Array[BlockAssignment]:
	return []

func choose_target(valid_targets: Array[Damageable]) -> Damageable:
	return valid_targets[0] if not valid_targets.is_empty() else null
