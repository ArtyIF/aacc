class_name CarSteerOffsetProcessor extends CarPluginBase

# default:
# left value: 0.0
# right value: 2.0
# max input: 10.0
# input curve: 0.500
@export var steer_offset_curve: ProceduralCurve = ProceduralCurve.new()

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")

func process_plugin(delta: float) -> void:
	if not steer_offset_curve: return

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var offset: float = steer_offset_curve.sample(abs(local_velocity_linear.x)) * sign(local_velocity_linear.x)
	car.set_meta(&"steer_offset", offset)
