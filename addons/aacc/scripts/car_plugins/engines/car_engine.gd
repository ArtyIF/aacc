class_name CarEngine extends CarPluginBase

@export var top_speed: float = 50.0
@export var top_speed_reverse: float = 10.0
@export var engine_force: float = 10000.0

func _ready() -> void:
	car.add_input("Accelerate")
	car.add_input("Reverse")
	car.add_input("Brake")
	car.add_input("Handbrake")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_accelerate: float = car.get_input("Accelerate")
	var input_reverse: float = car.get_input("Reverse")

	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")
	var brake_value: float = max(input_brake, input_handbrake)
	input_accelerate *= 1.0 - brake_value
	input_reverse *= 1.0 - brake_value

	var force: Vector3 = Vector3.ZERO
	if car.get_param("LocalLinearVelocity").z > -top_speed:
		force += Vector3.FORWARD * input_accelerate * engine_force
	if car.get_param("LocalLinearVelocity").z < top_speed_reverse:
		force -= Vector3.FORWARD * input_reverse * engine_force
	car.add_force("Engine", force, true)
