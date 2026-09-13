## Integration test: holds the move_up action and asserts the player
## actually translates in the 3D world, using the real physics step
## rather than calling internal methods directly.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

func test_holding_move_up_moves_the_player() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	var start_position := player.global_position

	Input.action_press("move_up")
	for i in 20:
		await get_tree().physics_frame
	Input.action_release("move_up")

	var moved := player.global_position.distance_to(start_position)
	assert_gt(moved, 0.1, "player should have moved after holding move_up for 20 physics frames")
