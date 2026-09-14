## Integration tests for the real battle screen: walking into the forest
## enemy should start an actual BattleState-driven fight (not the old
## stub), with the enemy's real EnemyData, and choosing a card from the
## CardBrowser should actually play it through the engine.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

func _start_encounter(root: Node) -> Battle:
	var player: Player = root.get_node("Overworld/Player")
	var enemy: Enemy = root.get_node("Overworld/ForestEnemy")
	player.global_position = enemy.global_position

	var elapsed := 0.0
	while elapsed < 1.0:
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()

	var battle_holder: Node = root.get_node("BattleHolder")
	return battle_holder.get_child(0) as Battle

func test_walking_into_the_forest_enemy_starts_a_real_battle() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var battle := await _start_encounter(root)

	assert_not_null(battle, "a real Battle instance should be in BattleHolder")
	assert_eq(battle._enemy.display_name, "Forest Slime")
	assert_eq(battle._enemy.life, 10, "slime_enemy.tres sets starting_life to 10")
	assert_eq(battle._player.life, 20, "the player's first encounter should start at max life")

func test_choosing_a_land_card_actually_plays_it_through_the_engine() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var battle := await _start_encounter(root)

	# Inject a known land directly into hand rather than relying on what
	# the shuffled opening draw happened to contain, so this test is
	# deterministic regardless of draw luck.
	var land_data: CardData = load("res://data/cards/mossy_bank.tres")
	battle._player.hand.append(CardInstance.new(land_data))

	battle._on_card_chosen(land_data)

	assert_eq(battle._player.max_mana, 1, "choosing a land card should play it through BattleState")
