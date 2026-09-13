## A decoupled 2.5D camera rig: follows a target smoothly, and holds the
## configurable pitch/yaw that defines the game's isometric or angled
## top-down look. Movement and facing code read the camera's basis rather
## than hardcoding an axis, so changing yaw here never requires a code
## change elsewhere -- see the 2.5D technical law in CLAUDE.md.
class_name CameraRig
extends Node3D

@export var target_path: NodePath
@export var pitch_degrees: float = -30.0:
	set(value):
		pitch_degrees = value
		_apply_rotation()
@export var yaw_degrees: float = 45.0:
	set(value):
		yaw_degrees = value
		_apply_rotation()
@export var ortho_size: float = 14.0:
	set(value):
		ortho_size = value
		_apply_ortho_size()
@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3.ZERO

@onready var camera: Camera3D = %Camera3D

var _target: Node3D

func _ready() -> void:
	_apply_rotation()
	_apply_ortho_size()
	_target = get_node_or_null(target_path) as Node3D
	if _target:
		global_position = _target.global_position + offset

func _physics_process(delta: float) -> void:
	if _target == null:
		return
	var goal := _target.global_position + offset
	var t := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(goal, t)

## The camera's forward direction flattened onto the world XZ plane (the
## direction "up" on screen moves toward), used by movement and facing code
## so they stay correct at any yaw.
func flattened_forward() -> Vector3:
	var b := camera.global_transform.basis
	return Vector3(-b.z.x, 0.0, -b.z.z).normalized()

## The camera's right direction flattened onto the world XZ plane.
func flattened_right() -> Vector3:
	var b := camera.global_transform.basis
	return Vector3(b.x.x, 0.0, b.x.z).normalized()

func _apply_rotation() -> void:
	rotation_degrees = Vector3(pitch_degrees, yaw_degrees, 0.0)

func _apply_ortho_size() -> void:
	if camera:
		camera.size = ortho_size
