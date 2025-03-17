class_name CarHoldBoost extends CarPluginBase

@export var boost_force: float = 10000.0
@export var boost_top_speed: float = 55.0

func _ready() -> void:
	car.set_param(&"input_boost", 0.0)

func process_plugin(delta: float) -> void:
	if car.get_param(&"input_boost", 0.0) > 0.0:
		if abs(car.get_param(&"local_linear_velocity", Vector3.ZERO).z) <= boost_top_speed:
			var ground_coefficient: float = car.get_param(&"ground_coefficient", 0.0)
			if ground_coefficient < 1.0:
				car.set_force(&"boost_air", -car.global_basis.z * boost_force * (1.0 - ground_coefficient), false, to_global(car.center_of_mass) - car.global_position)
			if ground_coefficient > 0.0:
				car.set_force(&"boost_ground", Vector3.FORWARD * boost_force * ground_coefficient, true)
