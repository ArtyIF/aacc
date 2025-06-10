class_name CarLocalVelocityProcessor extends CarPluginBase

var local_velocity_linear: Vector3 = Vector3.ZERO
var local_velocity_angular: Vector3 = Vector3.ZERO
var local_velocity_z_sign: float = 0.0

func _ready() -> void:
	debuggable_properties = [
		&"local_velocity_linear",
		&"local_velocity_angular",
		&"local_velocity_z_sign",
	]

func process_plugin(delta: float) -> void:
	local_velocity_linear = car.global_basis.inverse() * car.linear_velocity
	local_velocity_angular = car.global_basis.inverse() * car.angular_velocity

	if abs(local_velocity_linear.z) >= 0.25: # TODO: make 0.25 settable
		local_velocity_z_sign = sign(local_velocity_linear.z)
	else:
		local_velocity_z_sign = 0.0

	# TODO: remove
	car.set_meta(&"local_angular_velocity", local_velocity_angular)
	car.set_meta(&"velocity_z_sign", local_velocity_z_sign)
