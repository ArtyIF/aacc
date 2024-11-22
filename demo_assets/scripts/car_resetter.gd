extends Node
@onready var _car: Car = AACCGlobal.current_car

func _physics_process(_delta: float) -> void:
	if _car.global_position.y < -12 or (_car.global_basis.y.y < 0.0 and _car.linear_velocity.length() < 0.1):
		_car.freeze = true
		_car.global_position = Vector3.ZERO
		_car.global_basis = Basis.IDENTITY
		_car.force_update_transform()
		_car.freeze = false
