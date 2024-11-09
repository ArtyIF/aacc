extends Node
@export var car: Car

func _physics_process(_delta: float) -> void:
	if car.global_position.y < -12.5 or (car.global_basis.y.y < 0.0 and car.linear_velocity.length() < 0.1):
		car.freeze = true
		car.global_position = Vector3.ZERO
		car.global_basis = Basis.IDENTITY
		car.force_update_transform()
		car.freeze = false
