## The player-controlled character in the 3D overworld. Movement is read
## camera-relative so it stays correct regardless of the CameraRig's
## configured yaw -- see the 2.5D technical law in CLAUDE.md.
class_name Player
extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 30.0
@export var camera_rig_path: NodePath

@onready var _sprite: Sprite3D = %Sprite3D

var _camera_rig: CameraRig
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("player")
	up_direction = Vector3.UP
	floor_snap_length = 0.2
	_camera_rig = get_node_or_null(camera_rig_path) as CameraRig
	SpriteDefaults.configure(_sprite, ArtRegistry.sprite(&"player"))

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
