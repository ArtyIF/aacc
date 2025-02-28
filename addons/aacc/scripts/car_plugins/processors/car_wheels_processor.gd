class_name CarWheelsProcessor extends CarPluginBase

class WheelInfo:
	var landed: bool
	var point: Vector3
	var normal: Vector3

var wheel_info: Dictionary[String, WheelInfo] = {}

func set_wheel_info(wheel_name: String):
	if not wheel_info.has(wheel_name):
		wheel_info[wheel_name] = WheelInfo.new()

func _ready() -> void:
	car.add_param("GroundAveragePoint", Vector3.ZERO)
	car.add_param("GroundAverageNormal", Vector3.ZERO)
	car.add_param("GroundCoefficient", 0.0)

func process_plugin(delta: float) -> void:
	for param_name: String in car.params.keys():
		var wheel_name: String = ""
		if param_name.begins_with("WheelLanded_"):
			wheel_name = param_name.substr(12)
			set_wheel_info(wheel_name)
			wheel_info[wheel_name].landed = car.get_param(param_name) as bool
		if param_name.begins_with("WheelPoint_"):
			wheel_name = param_name.substr(11)
			set_wheel_info(wheel_name)
			wheel_info[wheel_name].point = car.get_param(param_name) as Vector3
		if param_name.begins_with("WheelNormal_"):
			wheel_name = param_name.substr(12)
			set_wheel_info(wheel_name)
			wheel_info[wheel_name].normal = car.get_param(param_name) as Vector3

	var total_landed: int = 0
	var average_point: Vector3 = Vector3.ZERO
	var average_normal: Vector3 = Vector3.ZERO
	var ground_coefficient: float = 0.0

	for wheel: WheelInfo in wheel_info.values():
		if wheel.landed:
			total_landed += 1
			average_point += wheel.point
			average_normal += wheel.normal

	ground_coefficient = float(total_landed) / len(wheel_info)
	average_point /= total_landed
	average_normal = average_normal.normalized()

	car.set_param("GroundAveragePoint", average_point)
	car.set_param("GroundAverageNormal", average_normal)
	car.set_param("GroundCoefficient", ground_coefficient)
