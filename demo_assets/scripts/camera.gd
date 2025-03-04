extends Camera3D

@onready var _car: Car = AACCGlobal.car
@onready var _follow_node: Node3D = _car.get_node("Visuals")
@onready var _follow_offset_node: Node3D = _car.get_node("FollowCameraOffset")
@onready var _hood_camera_node: Node3D = _car.get_node("HoodCamera")
@onready var _last_position: Vector3 = _follow_node.global_position

@onready var _direction_target: Vector3 = global_basis.z
@onready var _smoothed_direction: Vector3 = global_basis.z
@onready var _up_vector_target: Vector3 = Vector3.UP
@onready var _smoothed_up_vector: Vector3 = Vector3.UP

var use_hood_camera: bool = false

func _ready() -> void:
	process_priority = 1000

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("aaccdemo_camera"):
		use_hood_camera = not use_hood_camera

	var smooth_amount: float = 10.0

	if use_hood_camera:
		global_position = _hood_camera_node.global_position
		_direction_target = _hood_camera_node.global_basis.z
		_up_vector_target = _hood_camera_node.global_basis.y
	else:
		_up_vector_target = Vector3.UP
		var velocity: Vector3 = (_last_position - _follow_node.global_position) / delta
		velocity = velocity.slide(_up_vector_target)
		smooth_amount = clamp(remap(velocity.length(), 0.0, 10.0, 0.0, 10.0), 0.0, 10.0)
		_direction_target = velocity.normalized()

	if _up_vector_target.distance_to(_smoothed_up_vector) > 0.001:
		_smoothed_up_vector = _smoothed_up_vector.slerp(_up_vector_target, delta * 10.0)

	if _direction_target.distance_to(_smoothed_direction) > 0.001:
		_smoothed_direction = _smoothed_direction.slerp(_direction_target, delta * smooth_amount)
		_smoothed_direction = _smoothed_direction.slide(_smoothed_up_vector).normalized()
	global_basis = Basis.looking_at(-_smoothed_direction, _smoothed_up_vector)

	if not use_hood_camera:
		var follow_camera_offset: Vector3 = _follow_offset_node.position
		global_position = _follow_node.global_position + (_smoothed_direction * follow_camera_offset.z) + (_smoothed_up_vector * follow_camera_offset.y)

	_last_position = _follow_node.global_position
