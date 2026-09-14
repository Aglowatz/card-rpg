## The player-controlled character in the 3D overworld. Movement is read
## camera-relative so it stays correct regardless of the CameraRig's
## configured yaw -- see the 2.5D technical law in CLAUDE.md.
class_name Player
extends CharacterBody3D

## Emitted when the player presses "interact" while near one or more
## InteractArea zones. Carries the nearest interactable's owner node;
## Overworld decides what that node actually means (a vendor, a future
## NPC, ...) and re-emits accordingly -- see overworld.gd.
signal interact_requested(target: Node3D)

@export var speed: float = 5.0
@export var acceleration: float = 30.0
@export var camera_rig_path: NodePath

@onready var _sprite: Sprite3D = %Sprite3D
@onready var _interact_sensor: Area3D = $InteractSensor

var _camera_rig: CameraRig
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _nearby_interactables: Array[Area3D] = []

func _ready() -> void:
	add_to_group("player")
	up_direction = Vector3.UP
	floor_snap_length = 0.2
	_camera_rig = get_node_or_null(camera_rig_path) as CameraRig
	SpriteDefaults.configure(_sprite, ArtRegistry.sprite(&"player"))
	_interact_sensor.area_entered.connect(_on_interact_sensor_area_entered)
	_interact_sensor.area_exited.connect(_on_interact_sensor_area_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not _nearby_interactables.is_empty():
		var target := _nearby_interactables[0].get_parent() as Node3D
		if target:
			interact_requested.emit(target)
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var move_dir := Vector3.ZERO
	if input_dir != Vector2.ZERO and _camera_rig:
		var forward := _camera_rig.flattened_forward()
		var right := _camera_rig.flattened_right()
		move_dir = (right * input_dir.x + forward * -input_dir.y).normalized()

	var target_velocity := move_dir * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = -0.1

	move_and_slide()

func _on_interact_sensor_area_entered(area: Area3D) -> void:
	if not _nearby_interactables.has(area):
		_nearby_interactables.append(area)

func _on_interact_sensor_area_exited(area: Area3D) -> void:
	_nearby_interactables.erase(area)
