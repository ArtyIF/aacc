class_name CarEngineBasic extends CarPluginBase

@export var top_speed: float = 50.0
@export var top_speed_reverse: float = 10.0
@export var engine_force: float = 10000.0

func _ready() -> void:
	car.add_input("Accelerate")
	car.add_input("Reverse")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_accelerate: float = car.get_input("Accelerate")
	var input_reverse: float = car.get_input("Reverse")

	var force: Vector3 = Vector3.ZERO
	if car.get_param("LocalLinearVelocity").z > -top_speed:
		force += Vector3.FORWARD * input_accelerate * engine_force
	if car.get_param("LocalLinearVelocity").z < top_speed_reverse:
		force -= Vector3.FORWARD * input_reverse * engine_force
	car.add_force("Engine", force, true)
