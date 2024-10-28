extends Camera3D
@export var car: Car
@export var follow_velocity: bool = false

@onready var _follow_node: Node3D = car.get_node("Visuals")

@onready var _last_position: Vector3 = _follow_node.global_position
var _direction_target: Vector3 = -Vector3.FORWARD

var _smoothed_direction: Vector3 = -Vector3.FORWARD
var _smoothed_position: Vector3 = -Vector3.FORWARD

# TODO: use _process and implement smoothing for cars
func _process(delta: float) -> void:
	if follow_velocity:
		var velocity: Vector3 = _last_position - _follow_node.global_position
		if Plane.PLANE_XZ.project(velocity).length() >= delta:
			_direction_target = Plane.PLANE_XZ.project(velocity.normalized())
	else:
		if car.ground_coefficient > 0.0:
			_direction_target = Plane.PLANE_XZ.project(_follow_node.global_basis.z)

	_smoothed_direction = _smoothed_direction.slerp(_direction_target, delta * 10.0)
	_smoothed_position = _smoothed_position.lerp(_follow_node.global_position + (_smoothed_direction * 4.0) + (Vector3.UP * 2.0), delta * 20.0)

	global_position = _smoothed_position
	global_basis = Basis.looking_at(-_smoothed_direction)
	_last_position = _follow_node.global_position
