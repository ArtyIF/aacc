class_name CarEngineBasic extends CarPluginBase

@export var top_speed_forward: float = 50.0
@export var top_speed_backward: float = 10.0
@export var force_amount: float = 10000.0

func process_plugin(delta: float) -> void:
	var input_forward: float = car.get_input("Forward")
	var input_backward: float = car.get_input("Backward")
	var force: Vector3 = Vector3.FORWARD * (input_forward - input_backward) * force_amount * car.get_param("GroundCoefficient", 1.0)
	# TODO: top speeds
	car.add_force("Engine", force)
