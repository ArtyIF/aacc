class_name CarBrake extends CarPluginBase

@export var max_brake_velocity: float = 0.1
@export var brake_force: float = 15000.0
@export var handbrake_force: float = 20000.0

var brake_speed: float = 0.0
var actual_brake_force: float = 0.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	car.set_meta(&"input_brake", 0.0)
	car.set_meta(&"input_handbrake", false)

	debuggable_parameters = [
		&"brake_speed",
		&"actual_brake_force",
	]

func process_plugin(delta: float) -> void:
	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var input_brake: float = car.get_meta(&"input_brake")
	var input_handbrake: bool = car.get_meta(&"input_handbrake")

	brake_speed = plugin_lvp.local_velocity_linear.z / max_brake_velocity
	actual_brake_force = handbrake_force if input_handbrake else (brake_force * input_brake)

	if is_zero_approx(brake_speed * actual_brake_force):
		return

	var force: Vector3 = Vector3.FORWARD * clamp(brake_speed, -1.0, 1.0) * actual_brake_force
	car.set_force(&"brake", force, true)
