## The capstone: a full card duel -- draw, play cards, resolve effects,
## take damage, win or lose -- played entirely from this test with no
## window opened. This is docs/ROADMAP.md Phase 4's literal "done when"
## criterion.
extends GutTest

func _land_data() -> CardData:
	var data := CardData.new()
	data.id = &"land"
	data.card_type = CardData.CardType.LAND
	return data

func _bolt_data(amount: int) -> CardData:
	var data := CardData.new()
	data.id = &"bolt"
	data.card_type = CardData.CardType.SPELL
	data.cost = 1
	data.effects = [DealDamage.new(amount)]
	return data

## Stands in for the human side (Phase 5 will wire real UI to this same
## play_land()/play_card() API): plays a land if it hasn't yet, then plays
## every currently-affordable card in hand.
func _play_naive_turn(battle: BattleState, combatant: Combatant) -> void:
	if not combatant.has_played_land_this_turn:
		for card in combatant.hand:
			if card.data.card_type == CardData.CardType.LAND:
				battle.play_land(combatant, card)
				break
	var hand_snapshot: Array[CardInstance] = combatant.hand.duplicate()
	for card in hand_snapshot:
		if card.data.card_type != CardData.CardType.LAND and card.data.cost <= combatant.mana:
			battle.play_card(combatant, card)

func test_full_duel_can_be_played_headless_to_a_winner() -> void:
	var player := Combatant.new(20, "Player")
	player.hand.append(CardInstance.new(_land_data()))
	player.hand.append(CardInstance.new(_bolt_data(5)))
	player.hand.append(CardInstance.new(_bolt_data(5)))

	var enemy_data := EnemyData.new()
	enemy_data.deck_strategy = EnemyData.DeckStrategy.RANDOM
	var enemy := Combatant.new(10, "Enemy")
	enemy.hand.append(CardInstance.new(_land_data()))
	enemy.hand.append(CardInstance.new(_bolt_data(2)))

	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, DeckPlayingController.new(enemy_data)]
	var battle := BattleState.new([player, enemy], controllers, providers)

	var max_iterations := 200
	var iterations := 0
	while not battle.is_over() and iterations < max_iterations:
		if battle.active_combatant() == player and battle.phase == BattleState.Phase.MAIN_1:
			_play_naive_turn(battle, player)
		battle.advance_phase()
		iterations += 1

	assert_true(battle.is_over(), "the duel should reach a winner within %d phase advances" % max_iterations)
	assert_eq(battle.winner(), player)
