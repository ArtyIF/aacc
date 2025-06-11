class_name CarDownforce extends CarPluginBase

@export var min_ground_coefficient: float = 0.5
@export var downforce: float = 10000.0
# default:
# left value: 0.0
# right value: 1.0
# max input: 20.0
# input curve: 1.000
@export var downforce_speed_curve: ProceduralCurve

@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func process_plugin(delta: float) -> void:
	if plugin_wp.ground_coefficient < min_ground_coefficient: return

	var downforce_amount: float = downforce * downforce_speed_curve.sample(car.linear_velocity.length())
	car.set_force(&"downforce", -plugin_wp.ground_average_normal * downforce_amount, false, to_global(car.center_of_mass) - car.global_position)
