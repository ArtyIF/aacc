class_name CarLocalVelocityProcessor extends CarPluginBase

func _ready() -> void:
	car.set_param("local_linear_velocity", Vector3.ZERO)
	car.set_param("local_angular_velocity", Vector3.ZERO)
	car.set_param("velocity_z_sign", 0.0)

func process_plugin(delta: float) -> void:
	var local_linear_velocity: Vector3 = car.global_transform.basis.inverse() * car.linear_velocity
	var local_angular_velocity: Vector3 = car.global_transform.basis.inverse() * car.angular_velocity
	car.set_param("local_linear_velocity", local_linear_velocity)
	car.set_param("local_angular_velocity", local_angular_velocity)

	if abs(local_linear_velocity.z) >= 0.25: # TODO: make 0.25 settable
		car.set_param("velocity_z_sign", sign(local_linear_velocity.z))
	else:
		car.set_param("velocity_z_sign", 0.0)
