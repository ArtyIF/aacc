class_name CarLocalVelocityProcessor extends CarPluginBase

func _ready() -> void:
	car.add_param("LocalLinearVelocity", Vector3.ZERO)
	car.add_param("LocalAngularVelocity", Vector3.ZERO)

func process_plugin(delta: float) -> void:
	car.set_param("LocalLinearVelocity", car.global_transform.basis.inverse() * car.linear_velocity)
	car.set_param("LocalAngularVelocity", car.global_transform.basis.inverse() * car.angular_velocity)
