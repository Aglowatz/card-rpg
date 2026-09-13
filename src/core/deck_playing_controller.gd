## Plays an enemy's turn from its own deck, choosing cards per its
## configured EnemyData.deck_strategy. All three strategies only ever
## decide *which* card -- they always play through BattleState's normal
## play_card()/play_land(), the same entry points a human will use later.
class_name DeckPlayingController
extends EnemyController

var enemy_data: EnemyData
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _sequence_index: int = 0

func _init(p_enemy_data: EnemyData) -> void:
	enemy_data = p_enemy_data

func take_turn(battle: BattleState, combatant: Combatant) -> void:
	_maybe_play_land(battle, combatant)
	match enemy_data.deck_strategy:
		EnemyData.DeckStrategy.RANDOM:
			_take_turn_random(battle, combatant)
		EnemyData.DeckStrategy.SCRIPTED_SEQUENCE:
			_take_turn_scripted_sequence(battle, combatant)
		EnemyData.DeckStrategy.WEIGHTED_POOL:
			_take_turn_weighted_pool(battle, combatant)

func _maybe_play_land(battle: BattleState, combatant: Combatant) -> void:
	if combatant.has_played_land_this_turn:
		return
	for card in combatant.hand:
		if card.data.card_type == CardData.CardType.LAND:
			battle.play_land(combatant, card)
			return

func _take_turn_random(battle: BattleState, combatant: Combatant) -> void:
	while true:
		var candidates := _affordable_playable_cards(combatant)
		if candidates.is_empty():
			return
		var card := candidates[rng.randi() % candidates.size()]
		battle.play_card(combatant, card)

## Walks scripted_sequence in order across the whole battle (the index is
## never reset per turn). Ids that aren't currently castable are skipped
## permanently, not retried on a later turn.
func _take_turn_scripted_sequence(battle: BattleState, combatant: Combatant) -> void:
	while _sequence_index < enemy_data.scripted_sequence.size():
		var card_id := enemy_data.scripted_sequence[_sequence_index]
		_sequence_index += 1
		var card := _find_in_hand(combatant, card_id)
		if card != null and combatant.mana >= card.data.cost:
			battle.play_card(combatant, card)

func _take_turn_weighted_pool(battle: BattleState, combatant: Combatant) -> void:
	while true:
		var candidates := _affordable_weighted_entries(combatant)
		if candidates.is_empty():
			return
		var entry := _pick_weighted(candidates)
		var card := _find_in_hand(combatant, entry.card_id)
		battle.play_card(combatant, card)

func _pick_weighted(candidates: Array[WeightedCardEntry]) -> WeightedCardEntry:
	var total_weight := 0.0
	for entry in candidates:
		total_weight += entry.weight
	var roll := rng.randf() * total_weight
	for entry in candidates:
		if roll < entry.weight:
			return entry
		roll -= entry.weight
	return candidates[candidates.size() - 1]

func _affordable_playable_cards(combatant: Combatant) -> Array[CardInstance]:
	var candidates: Array[CardInstance] = []
	for card in combatant.hand:
		if card.data.card_type != CardData.CardType.LAND and card.data.cost <= combatant.mana:
			candidates.append(card)
	return candidates

func _affordable_weighted_entries(combatant: Combatant) -> Array[WeightedCardEntry]:
	var candidates: Array[WeightedCardEntry] = []
	for entry in enemy_data.weighted_pool:
		var card := _find_in_hand(combatant, entry.card_id)
		if card != null and card.data.cost <= combatant.mana:
			candidates.append(entry)
	return candidates

func _find_in_hand(combatant: Combatant, card_id: StringName) -> CardInstance:
	for card in combatant.hand:
		if card.data.id == card_id:
			return card
	return null
