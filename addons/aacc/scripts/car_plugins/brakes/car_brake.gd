class_name CarBrake extends CarPluginBase

@export var brake_force: float = 20000.0

func _ready() -> void:
	car.add_input("Brake")
	car.add_input("Handbrake")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")
	var brake_value: float = max(input_brake, input_handbrake)

	var brake_speed: float = clamp(car.get_param("LocalLinearVelocity").z, -1.0, 1.0)
	var force: Vector3 = Vector3.FORWARD * brake_value * brake_speed * brake_force
	car.add_force("Brake", force, true)
