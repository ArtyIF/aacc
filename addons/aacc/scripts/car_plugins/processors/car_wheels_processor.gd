class_name CarWheelsProcessor extends CarPluginBase

@export var wheel_names: Array[StringName] = []

class WheelInfo:
	var landed: bool
	var point: Vector3
	var normal: Vector3

func _ready() -> void:
	car.set_param("GroundAveragePoint", Vector3.ZERO)
	car.set_param("GroundAverageNormal", Vector3.ZERO)
	car.set_param("GroundCoefficient", 0.0)

func process_plugin(delta: float) -> void:
	var total_landed: int = 0
	var average_point: Vector3 = Vector3.ZERO
	var average_normal: Vector3 = Vector3.ZERO
	var ground_coefficient: float = 0.0

	for wheel_name: StringName in wheel_names:
		if car.get_param("WheelLanded", false, wheel_name):
			total_landed += 1
			average_point += car.get_param("WheelPoint", Vector3.ZERO, wheel_name)
			average_normal += car.get_param("WheelNormal", Vector3.ZERO, wheel_name)

	if total_landed > 0:
		ground_coefficient = float(total_landed) / len(wheel_names)
		average_point /= total_landed
		average_normal = average_normal.normalized()
	else:
		average_normal = Vector3.UP

	car.set_param("GroundAveragePoint", average_point)
	car.set_param("GroundAverageNormal", average_normal)
	car.set_param("GroundCoefficient", ground_coefficient)
