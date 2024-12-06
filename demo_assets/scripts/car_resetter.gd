extends Node
@onready var _car: Car = AACCGlobal.current_car

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("aaccdemo_reset"):
		_car.global_position = Vector3(0.0, 0.5, 0.0)
		_car.global_basis = Basis.IDENTITY
		_car.linear_velocity = Vector3.ZERO
		_car.angular_velocity = Vector3.ZERO
		_car.force_update_transform()
		_car.reset_physics_interpolation()
		_car.reset()
