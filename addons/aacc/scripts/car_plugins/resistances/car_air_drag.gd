class_name CarAirDrag extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_velocity_min: float = deg_to_rad(10.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_velocity_knee: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec²") var max_drag_amount: float = deg_to_rad(30.0)

var drag_knee: float = 0.0

@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	debuggable_parameters = [
		&"drag_knee",
	]

func process_plugin(delta: float) -> void:
	if plugin_wp.ground_coefficient > 0.0:
		return

	# TODO: make it move towards a certain up vector, maybe just up or cast a ray down and use the normal
	if car.angular_velocity.length() > target_velocity_min:
		drag_knee = clamp(inverse_lerp(target_velocity_min, target_velocity_min + target_velocity_knee, car.angular_velocity.length()), 0.0, 1.0)
		car.set_torque(&"air_drag", (-car.angular_velocity / delta).limit_length(max_drag_amount) * car.mass * drag_knee)
