class_name CarDownforce extends CarPluginBase

@export var min_ground_coefficient: float = 0.5
@export var downforce: float = 10000.0
# default:
# left value: 0.0
# right value: 1.0
# max input: 20.0
# input curve: 1.000
@export var downforce_speed_curve: ProceduralCurve

func process_plugin(delta: float) -> void:
	if car.get_param("GroundCoefficient", 0.0) < min_ground_coefficient: return

	var downforce_amount: float = downforce * downforce_speed_curve.sample(car.linear_velocity.length())
	car.set_force("Downforce", -car.get_param("GroundAverageNormal", Vector3.UP) * downforce_amount, false, to_global(car.center_of_mass) - car.global_position)
