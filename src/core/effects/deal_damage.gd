## Deals a fixed amount of damage to a target Damageable (a creature or a
## combatant's face).
class_name DealDamage
extends Effect

@export var amount: int = 1

func _init(p_amount: int = 1) -> void:
	amount = p_amount

func resolve(ctx: EffectContext) -> void:
	if ctx.target == null:
		push_error("DealDamage.resolve() called with no target on context")
		return
	ctx.target.take_damage(amount)
	ctx.append_log("%s deals %d damage" % [
		ctx.source.data.display_name if ctx.source else "unknown",
		amount,
	])

func describe() -> String:
	return "Deal %d damage." % amount
