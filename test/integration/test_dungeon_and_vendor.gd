## Integration tests for the two pieces added alongside the town/forest/
## dungeon world: the dungeon's scripted-intent boss, and the town
## vendor's interact-to-browse flow.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

func test_walking_into_the_dungeon_enemy_starts_its_scripted_battle() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	var dungeon_enemy: Enemy = root.get_node("Overworld/DungeonEnemy")
	player.global_position = dungeon_enemy.global_position

	var elapsed := 0.0
	while elapsed < 1.0:
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()

	var battle_holder: Node = root.get_node("BattleHolder")
	var battle := battle_holder.get_child(0) as Battle

	assert_not_null(battle, "walking into the dungeon enemy should start a battle")
	assert_eq(battle._enemy.display_name, "Dungeon Warden")
	assert_eq(battle._enemy.life, 25, "dungeon_warden.tres sets starting_life to 25")

func test_dungeon_warden_alternates_summoning_and_damage() -> void:
	# Exercises the actual EnemyData authored for the dungeon fight,
	# independent of the overworld/UI, proving the "creature every other
	# turn, otherwise 2 damage" requirement holds for the real data file.
	var enemy_data: EnemyData = load("res://data/enemies/dungeon_warden.tres")
	var controller := ScriptedIntentController.new(enemy_data)

	var warden := Combatant.new(enemy_data.starting_life, "Dungeon Warden")
	var player := Combatant.new(20, "Player")
	var providers: Array[ChoiceProvider] = [AutoChoiceProvider.new(), AutoChoiceProvider.new()]
	var controllers: Array[EnemyController] = [null, controller]
	var battle := BattleState.new([player, warden], controllers, providers)

	controller.take_turn(battle, warden)
	assert_eq(warden.battlefield.size(), 1, "the first intent should summon a creature")
	assert_eq(player.life, 20)

	controller.take_turn(battle, warden)
	assert_eq(player.life, 18, "the second intent should deal 2 damage")
	assert_eq(warden.battlefield.size(), 1)

	controller.take_turn(battle, warden)
	assert_eq(warden.battlefield.size(), 2, "the sequence should loop back to summoning")

func test_interacting_with_the_vendor_opens_the_card_browser() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	var vendor: Node3D = root.get_node("Overworld/Vendor")

	var inventory_layer: CanvasLayer = root.get_node("InventoryLayer")
	assert_false(inventory_layer.visible, "the vendor browser should start closed")

	player.interact_requested.emit(vendor)
	await get_tree().process_frame

	assert_true(inventory_layer.visible, "interacting with the vendor should open the card browser")
