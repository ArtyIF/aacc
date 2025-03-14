class_name CarSteerOffsetProcessor extends CarPluginBase

# default:
# left value: 0.0
# right value: 2.0
# max input: 10.0
# input curve: 0.500
@export var steer_offset_curve: ProceduralCurve = ProceduralCurve.new()

func process_plugin(delta: float) -> void:
	if not steer_offset_curve: return

	var local_linear_velocity: Vector3 = car.get_param("local_linear_velocity", Vector3.ZERO)
	var offset: float = steer_offset_curve.sample(abs(local_linear_velocity.x)) * sign(local_linear_velocity.x)
	car.set_param("steer_offset", offset)
