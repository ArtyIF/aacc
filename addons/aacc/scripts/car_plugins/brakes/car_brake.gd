class_name CarBrake extends CarPluginBase

@export var max_brake_velocity: float = 0.1
@export var brake_force: float = 15000.0
@export var handbrake_force: float = 20000.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")

func _ready() -> void:
	car.set_meta(&"input_brake", 0.0)
	car.set_meta(&"input_handbrake", false)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		return

	var input_brake: float = car.get_meta(&"input_brake", 0.0)
	var input_handbrake: bool = car.get_meta(&"input_handbrake", false)

	if is_zero_approx(input_brake) and not input_handbrake:
		return

	var brake_speed: float = plugin_lvp.local_velocity_linear.z / max_brake_velocity
	car.set_meta(&"brake_speed", brake_speed)
	var actual_brake_force: float = handbrake_force if input_handbrake else (brake_force * input_brake)
	var force: Vector3 = Vector3.FORWARD * clamp(brake_speed, -1.0, 1.0) * actual_brake_force
	car.set_force(&"brake", force, true)
