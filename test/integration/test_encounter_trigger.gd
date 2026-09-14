## Integration tests for the touch-to-battle trigger, the way a player
## actually experiences it: physically approaching or overlapping the
## enemy in the 3D world.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

## Waits past the fade-out tween GameRoot runs before it actually
## instantiates the battle scene (see features/ui/main.gd).
func _wait_for_battle_transition(node: Node) -> void:
	var elapsed := 0.0
	while elapsed < 1.0:
		await node.get_tree().physics_frame
		elapsed += node.get_physics_process_delta_time()

func test_player_overlapping_enemy_triggers_a_battle() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	var enemy: Enemy = root.get_node("Overworld/ForestEnemy")

	player.global_position = enemy.global_position
	await _wait_for_battle_transition(self)

	var battle_holder: Node = root.get_node("BattleHolder")
	assert_gt(battle_holder.get_child_count(), 0, "overlapping the enemy should have started a battle")

func test_walking_toward_the_enemy_triggers_a_battle() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	var enemy: Enemy = root.get_node("Overworld/ForestEnemy")
	var camera_rig: CameraRig = root.get_node("Overworld/CameraRig")

	# Start the player a short walk away from the enemy, directly behind
	# where "move_up" will actually push it -- computed from the camera's
	# real forward vector rather than assumed, since the default camera
	# yaw isn't aligned to a world axis. This exercises the actual
	# physical approach a player experiences, not just a teleport.
	var forward := camera_rig.flattened_forward()
	player.global_position = enemy.global_position - forward * 2.0

	Input.action_press("move_up")
	var elapsed := 0.0
	while elapsed < 2.0:
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()
	Input.action_release("move_up")

	await _wait_for_battle_transition(self)

	var battle_holder: Node = root.get_node("BattleHolder")
	assert_gt(battle_holder.get_child_count(), 0, "walking into the enemy should have started a battle")
