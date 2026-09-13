## Base class for a composable card effect.
##
## Effects are data (Resources), not one-off scripts per card. A card's
## behavior is an Array[Effect] of small, reusable primitives like
## DealDamage or DrawCards. Subclasses override resolve() and describe().
##
## Effects must stay engine-agnostic: no Node, no Texture2D, no await, so
## that combat resolution is runnable and assertable with no scene tree.
class_name Effect
extends Resource

func resolve(_ctx: EffectContext) -> void:
	push_error("Effect.resolve() not implemented on %s" % get_script().resource_path)

func describe() -> String:
	return ""
