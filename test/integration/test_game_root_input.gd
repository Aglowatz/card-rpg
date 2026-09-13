## Integration test: simulates real input events against the running
## GameRoot scene, the way a player's keypress actually arrives, rather
## than calling internal methods directly. Exists specifically to catch
## the class of bug where wiring looks right on paper but input never
## reaches the handler.
extends GutTest

const MAIN_SCENE := preload("res://features/ui/main.tscn")

func _press_key(keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	await get_tree().process_frame

	var release := InputEventKey.new()
	release.physical_keycode = keycode
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame

func test_toggle_inventory_key_opens_inventory() -> void:
	var root: Node = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame

	var inventory_layer: CanvasLayer = root.get_node("InventoryLayer")
	assert_false(inventory_layer.visible, "inventory should start closed")

	await _press_key(KEY_I)

	assert_true(inventory_layer.visible, "pressing I should open the inventory")
