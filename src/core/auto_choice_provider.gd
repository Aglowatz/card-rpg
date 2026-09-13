## The v1 default ChoiceProvider: attacks with everything able to, blocks
## only on a favorable trade, and targets a combatant's face over a
## creature when both are valid. Used for AI-controlled combatants, and as
## a stand-in for the human side until Phase 5 wires up a real UI-backed
## provider.
class_name AutoChoiceProvider
extends ChoiceProvider

func choose_attackers(available: Array[CardInstance]) -> Array[CardInstance]:
	var attackers: Array[CardInstance] = []
	for creature in available:
		attackers.append(creature)
	return attackers

## Blocks only when the trade is favorable: the blocker survives and the
## attacker doesn't. Whether the defender is facing lethal isn't available
## through this interface in v1, so that refinement is deferred.
func choose_blockers(attackers: Array[CardInstance], available: Array[CardInstance]) -> Array[BlockAssignment]:
	var blocks: Array[BlockAssignment] = []
	var used: Array[CardInstance] = []
	for attacker in attackers:
		for blocker in available:
			if used.has(blocker):
				continue
			var blocker_survives := attacker.data.power < blocker.current_toughness()
			var attacker_dies := blocker.data.power >= attacker.current_toughness()
			if blocker_survives and attacker_dies:
				blocks.append(BlockAssignment.new(attacker, blocker))
				used.append(blocker)
				break
	return blocks

func choose_target(valid_targets: Array[Damageable]) -> Damageable:
	for target in valid_targets:
		if target is Combatant:
			return target
	return valid_targets[0] if not valid_targets.is_empty() else null
