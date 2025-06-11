class_name CarSteerOffsetProcessor extends CarPluginBase

# default:
# left value: 0.0
# right value: 2.0
# max input: 10.0
# input curve: 0.500
@export var steer_offset_curve: ProceduralCurve = ProceduralCurve.new()

var steer_offset: float = 0.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")

func _ready() -> void:
	debuggable_parameters = [
		&"steer_offset",
	]

func process_plugin(delta: float) -> void:
	if not steer_offset_curve: return

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	steer_offset = steer_offset_curve.sample(abs(local_velocity_linear.x)) * sign(local_velocity_linear.x)
