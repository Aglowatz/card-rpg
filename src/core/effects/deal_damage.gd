## Deals a fixed amount of damage to a target CardInstance.
class_name DealDamage
extends Effect

@export var amount: int = 1

func _init(p_amount: int = 1) -> void:
	amount = p_amount

func resolve(ctx: EffectContext) -> void:
	if ctx.target == null:
		push_error("DealDamage.resolve() called with no target on context")
		return
	ctx.deal_damage(ctx.target, amount)

func describe() -> String:
	return "Deal %d damage." % amount
