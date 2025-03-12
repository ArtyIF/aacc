class_name CarStickingForce extends CarPluginBase

@export var wheels: Array[CarWheelSuspension] = []
@export var sticking_force: float = 10000.0
# default:
# left value: 0.0
# right value: 1.0
# max input: 20.0
# input curve: 0.500
@export var sticking_force_speed_curve: ProceduralCurve

func process_plugin(delta: float) -> void:
	for wheel: CarWheelSuspension in wheels:
		if wheel.is_landed:
			var buffer: float = (wheel.distance - wheel.wheel_radius - wheel.suspension_length) / wheel.buffer_length
			buffer = clamp(buffer, 0.0, 1.0)

			var stick_force: float = sticking_force * buffer * sticking_force_speed_curve.sample(car.linear_velocity.length())
			car.set_force("StickingForce" + wheel.name, -wheel.collision_normal * stick_force, false, wheel.collision_point - car.global_position)
