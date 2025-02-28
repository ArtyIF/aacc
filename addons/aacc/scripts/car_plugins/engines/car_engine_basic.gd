class_name CarEngineBasic extends CarPluginBase

@export var top_speed_forward: float = 50.0
@export var force_amount: float = 10000.0

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_accelerate: float = car.get_input("Accelerate")

	var force: Vector3 = Vector3.ZERO
	if car.get_param("LocalLinearVelocity").z > -top_speed_forward:
		force = Vector3.FORWARD * input_accelerate * force_amount
	car.add_force("Engine", force, true)
