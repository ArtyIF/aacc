extends Camera3D

@onready var _car: Car = AACCGlobal.car
@onready var _follow_node: Node3D = _car.get_node("Visuals")
@onready var _last_position: Vector3 = _follow_node.global_position

@onready var _direction_target: Vector3 = global_basis.z
@onready var _smoothed_direction: Vector3 = global_basis.z

func _ready() -> void:
	process_priority = 1000

func _physics_process(delta: float) -> void:
	var project_plane: Plane = Plane(Vector3.UP)
	
	var velocity: Vector3 = (_last_position - _follow_node.global_position) / delta
	velocity = project_plane.project(velocity)
	var smooth_amount: float = clamp(remap(velocity.length(), 0.0, 10.0, 0.0, 10.0), 0.0, 10.0)

	_direction_target = velocity.normalized()

	_smoothed_direction = _smoothed_direction.slerp(_direction_target, delta * smooth_amount)
	_smoothed_direction = project_plane.project(_smoothed_direction).normalized()
	global_basis = Basis.looking_at(-_smoothed_direction, Vector3.UP)
	
	var follow_camera_offset: Vector3 = _car.get_node("FollowCameraOffset").position
	global_position = _follow_node.global_position + (_smoothed_direction * follow_camera_offset.z) + (Vector3.UP * follow_camera_offset.y)

	_last_position = _follow_node.global_position
