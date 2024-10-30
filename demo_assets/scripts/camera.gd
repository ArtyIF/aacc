extends Camera3D

@export var car: Car

@export_range(0.0, 1.0) var forward_direction_amount: float = 0.5

@onready var _follow_node: Node3D = car.get_node("Visuals")

@onready var _last_position: Vector3 = _follow_node.global_position
var _direction_target: Vector3 = -Vector3.FORWARD

@onready var _smoothed_direction: Vector3 = global_basis.z

func _ready():
	process_priority = 1000

func _process(delta: float) -> void:
	var velocity: Vector3 = (_last_position - _follow_node.global_position) / delta
	velocity = Plane.PLANE_XZ.project(velocity)
	var smooth_amount: float = clamp(remap(velocity.length(), 0.0, 5.0, 0.0, 10.0), 0.0, 10.0)

	var _direction_target_velocity: Vector3 = velocity.normalized()
	var _direction_target_forward: Vector3 = velocity.normalized()
	if car.ground_coefficient > 0.0 and car.local_linear_velocity.z < 0.0:
		_direction_target_forward = Plane.PLANE_XZ.project(_follow_node.global_basis.z).normalized()
	_direction_target = _direction_target_velocity.slerp(_direction_target_forward, forward_direction_amount)

	_smoothed_direction = _smoothed_direction.slerp(_direction_target, delta * smooth_amount)
	global_basis = Basis.looking_at(-_smoothed_direction)
	global_position = _follow_node.global_position + (_smoothed_direction * lerp(4.0, 6.0, min(velocity.length() / 100.0, 1.0))) + (Vector3.UP * 2.0)

	_last_position = _follow_node.global_position
