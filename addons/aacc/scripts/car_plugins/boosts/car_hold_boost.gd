class_name CarHoldBoost extends CarPluginBase

@export var boost_force: float = 10000.0
@export var boost_top_speed: float = 55.0

func _ready() -> void:
	car.set_param(&"input_boost", 0.0)

func process_plugin(delta: float) -> void:
	if car.get_param(&"input_boost", 0.0) > 0.0:
		if abs(car.get_param(&"local_linear_velocity", Vector3.ZERO).z) <= boost_top_speed:
			if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
				car.set_force(&"boost", -car.global_basis.z * boost_force, false, to_global(car.center_of_mass) - car.global_position)
			else:
				car.set_force(&"boost", Vector3.FORWARD * boost_force, true)
