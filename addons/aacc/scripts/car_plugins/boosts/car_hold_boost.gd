class_name CarHoldBoost extends CarPluginBase

@export var boost_force: float = 10000.0

func _ready() -> void:
	car.set_param(&"input_boost", 0.0)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)): return

	if car.get_param(&"input_boost", 0.0) > 0.0:
		car.set_force(&"boost", Vector3.FORWARD * boost_force, true)
