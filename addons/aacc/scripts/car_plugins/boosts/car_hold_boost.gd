class_name CarHoldBoost extends CarPluginBase

@export var boost_force: float = 10000.0

func _ready() -> void:
	car.set_input("Boost", 0.0)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("ground_coefficient", 0.0)): return

	if car.get_input("Boost") > 0.0:
		car.set_force("Boost", Vector3.FORWARD * boost_force, true)
