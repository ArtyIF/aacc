class_name AACCPluginBasicLinearGrip extends AACCPlugin

@export var suspension: AACCPluginSuspension

func _physics_process(delta: float):
	if suspension.is_colliding:
		var force: float = -parent_car.local_linear_velocity.x * parent_car.mass
		var converted_force: Vector3 = convert_force(Vector3.RIGHT * force, suspension.average_wheel_collision_normal)
		parent_car.add_force(converted_force, suspension.average_wheel_collision_point, true)
