class_name CarEngineBasic extends CarPluginBase

@export var top_speed_forward: float = 50.0
@export var top_speed_backward: float = 10.0
@export var force_amount: float = 10000.0

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_input("Accelerate")

	var force: Vector3 = Vector3.ZERO
	if car.get_param("LocalLinearVelocity").z > -top_speed_forward and car.get_param("LocalLinearVelocity").z < top_speed_backward:
		force = Vector3.FORWARD * input_accelerate * force_amount * car.get_param("GroundCoefficient", 1.0)
	car.add_force("Engine", force)
