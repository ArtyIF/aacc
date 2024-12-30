extends Node3D

@onready var _car: Car = AACCGlobal.current_car

@onready var _offset_node_min: Node3D = _car.get_node("FollowCameraOffsetMin")
@onready var _offset_node_max: Node3D = _car.get_node("FollowCameraOffsetMax")
@onready var _offset_amount: float = 0.0

var _plane: Plane = Plane.PLANE_XZ
@onready var _direction: Vector3 = _plane.project(_car.global_basis.z)
@onready var _up_direction: Vector3 = Vector3.UP
@onready var _y_position: float = global_position.y
@onready var _original_y_position: float = _y_position

func reset():
	_offset_amount = 0.0
	_plane = Plane.PLANE_XZ
	_direction = _plane.project(_car.global_basis.z)
	_up_direction = Vector3.UP
	_y_position = _original_y_position

func _physics_process(delta: float) -> void:
	var global_com: Vector3 = _car.to_global(_car.center_of_mass)
	var final_position: Vector3 = global_com
	
	var target_up_direction: Vector3 = Vector3.UP
	if _car.ground_coefficient > 0.0:
		target_up_direction = _car.average_wheel_collision_normal
	if _up_direction.distance_to(target_up_direction) > 0.001:
		_up_direction = _up_direction.slerp(target_up_direction, delta)
	else:
		_up_direction = target_up_direction
	_plane = Plane(_up_direction)

	var target_offset_amount: float = (_car.linear_velocity.length() - 0.25) / _car.top_speed_forward
	_offset_amount = lerp(_offset_amount, target_offset_amount, 4.0 * delta)
	var offset: Vector3 = _offset_node_min.position.lerp(_offset_node_max.position, _offset_amount)

	final_position += _up_direction * offset.y

	var target_direction: Vector3 = -_car.linear_velocity.normalized()
	var slerp_amount: float = clamp((_car.linear_velocity.length() - 0.25) / 10.0, 0.0, 1.0)
	if _car.input_handbrake and _car.input_forward > 0.0 and _car.linear_velocity.length() <= 0.25:
		target_direction = _car.global_basis.z
		slerp_amount = _car.revs.get_current_value()
	if Input.is_action_pressed("aaccdemo_recenter_camera"):
		target_direction = _car.global_basis.z
		slerp_amount = 1.0
	if slerp_amount > 0.0:
		_direction = _plane.project(_direction.slerp(target_direction, slerp_amount * 10.0 * delta)).normalized()

	final_position += _direction * offset.z

	_y_position = lerp(_y_position, final_position.y, 20.0 * delta)
	final_position.y = _y_position
	global_position = final_position
