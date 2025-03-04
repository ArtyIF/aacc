class_name CarWheelsProcessor extends CarPluginBase

@export var wheel_names: Array[StringName] = []

class WheelInfo:
	var landed: bool
	var point: Vector3
	var normal: Vector3

var wheel_info: Dictionary[StringName, WheelInfo] = {}

func _ready() -> void:
	car.add_param("GroundAveragePoint", Vector3.ZERO)
	car.add_param("GroundAverageNormal", Vector3.ZERO)
	car.add_param("GroundCoefficient", 0.0)

	for wheel_name: StringName in wheel_names:
		wheel_info[wheel_name] = WheelInfo.new()

func process_plugin(delta: float) -> void:
	for wheel_name: StringName in wheel_names:
		wheel_info[wheel_name].landed = car.get_param("WheelLanded", false, wheel_name) as bool
		wheel_info[wheel_name].point = car.get_param("WheelPoint", Vector3.ZERO, wheel_name) as Vector3
		wheel_info[wheel_name].normal = car.get_param("WheelNormal", Vector3.ZERO, wheel_name) as Vector3

	var total_landed: int = 0
	var average_point: Vector3 = Vector3.ZERO
	var average_normal: Vector3 = Vector3.ZERO
	var ground_coefficient: float = 0.0

	for wheel: WheelInfo in wheel_info.values():
		if wheel.landed:
			total_landed += 1
			average_point += wheel.point
			average_normal += wheel.normal

	if total_landed > 0:
		ground_coefficient = float(total_landed) / len(wheel_info)
		average_point /= total_landed
		average_normal = average_normal.normalized()

	car.set_param("GroundAveragePoint", average_point)
	car.set_param("GroundAverageNormal", average_normal)
	car.set_param("GroundCoefficient", ground_coefficient)
