extends Node
@export var car: Car

func _physics_process(_delta: float) -> void:
	if car.global_position.y < -12.5:
		car.freeze = true
		car.global_position = Vector3.ZERO
		car.global_basis = Basis.IDENTITY
		car.force_update_transform()
		car.freeze = false
