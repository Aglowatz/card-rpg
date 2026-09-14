## Proves the overworld's boundary colliders actually stop the player at
## the edge of the playable area, rather than letting them walk off into
## the void -- the world previously had no edge colliders at all.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

func test_west_boundary_stops_the_player() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	player.global_position = Vector3(-9, 0, 0)

	# Drive the physics body directly at high speed toward the wall,
	# bypassing camera-relative input entirely -- this is a check on the
	# collider itself, not on movement input mapping.
	for i in 60:
		player.velocity.x = -20.0
		player.move_and_slide()
		await get_tree().physics_frame

	assert_gt(player.global_position.x, -10.4, "the west boundary should have stopped the player before x=-10.5")

func test_north_boundary_stops_the_player() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var player: Player = root.get_node("Overworld/Player")
	player.global_position = Vector3(0, 0, 9)

	for i in 60:
		player.velocity.z = 20.0
		player.move_and_slide()
		await get_tree().physics_frame

	assert_lt(player.global_position.z, 10.4, "the north boundary should have stopped the player before z=10.5")
