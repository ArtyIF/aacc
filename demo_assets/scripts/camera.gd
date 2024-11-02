extends Camera3D

@export var car: Car

@export_range(0.0, 1.0) var forward_direction_amount: float = 0.5

@onready var _follow_node: Node3D = car.get_node("Visuals")
@onready var _last_position: Vector3 = _follow_node.global_position

@onready var _direction_target: Vector3 = global_basis.z
@onready var _smoothed_direction: Vector3 = global_basis.z

var _up_vector_target: Vector3 = Vector3.UP
var _smoothed_up_vector: Vector3 = Vector3.UP
var _smoothed_handbrake: SmoothedFloat = SmoothedFloat.new(0.0, 2.0)

func _ready() -> void:
	process_priority = 1000

func _process(delta: float) -> void:
	_smoothed_handbrake.advance_to(1.0 if car.input_handbrake else 0.0, delta)
	
	if car.ground_coefficient > 0.0:
		_up_vector_target = car.average_wheel_collision_normal.normalized()
	else:
		_up_vector_target = _follow_node.global_basis.y.normalized()
	# BUG: somewhere around here it spams the debugger with the vector needing
	# to be normalized. It seems to be random for me sadly.
	_smoothed_up_vector = _smoothed_up_vector.slerp(_up_vector_target, delta)
	var project_plane: Plane = Plane(_smoothed_up_vector)
	
	var velocity: Vector3 = (_last_position - _follow_node.global_position) / delta
	velocity = project_plane.project(velocity)
	var smooth_amount: float = clamp(remap(velocity.length(), 0.0, 5.0, 0.0, 10.0), 0.0, 10.0)

	var direction_target_velocity: Vector3 = velocity.normalized()
	var direction_target_forward: Vector3 = direction_target_velocity
	var local_velocity_z: float = (_follow_node.global_basis.inverse() * velocity).z
	if car.ground_coefficient > 0.0:
		direction_target_forward = _follow_node.global_basis.z.normalized()
	_direction_target = direction_target_velocity.slerp(direction_target_forward, forward_direction_amount * clamp(local_velocity_z / 15.0, 0.0, 1.0) * (1.0 - _smoothed_handbrake.get_current_value()))

	_smoothed_direction = _smoothed_direction.slerp(_direction_target, delta * smooth_amount)
	_smoothed_direction = project_plane.project(_smoothed_direction).normalized()

	global_basis = Basis.looking_at(-_smoothed_direction, _smoothed_up_vector)
	global_position = _follow_node.global_position + (_smoothed_direction * lerp(4.0, 6.0, min(velocity.length() / 100.0, 1.0))) + (_smoothed_up_vector * 2.0)

	_last_position = _follow_node.global_position
