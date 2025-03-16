class_name CarWheelsProcessor extends CarPluginBase

@export var wheels: Array[CarWheelSuspension] = []

func _ready() -> void:
	car.set_param(&"ground_average_point", Vector3.ZERO)
	car.set_param(&"ground_average_normal", Vector3.ZERO)
	car.set_param(&"ground_coefficient", 0.0)

func process_plugin(delta: float) -> void:
	var total_landed: int = 0
	var average_point: Vector3 = Vector3.ZERO
	var average_normal: Vector3 = Vector3.ZERO
	var ground_coefficient: float = 0.0

	for wheel: CarWheelSuspension in wheels:
		if wheel.is_landed:
			total_landed += 1
			average_point += wheel.collision_point
			average_normal += wheel.collision_normal

	if total_landed > 0:
		ground_coefficient = float(total_landed) / len(wheels)
		average_point /= total_landed
		average_normal = average_normal.normalized()
	else:
		average_normal = Vector3.UP

	car.set_param(&"ground_average_point", average_point)
	car.set_param(&"ground_average_normal", average_normal)
	car.set_param(&"ground_coefficient", ground_coefficient)
