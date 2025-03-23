class_name CarForceProcessor extends CarPluginBase

@export_group("Grip", "grip_")
@export var grip_linear: float = 40000.0
@export var grip_angular: float = 20000.0

@export_subgroup("Reduced Grip", "reduced_grip_")
# default:
# left value: 1.0
# right value: 0.5
# max input: 10.0
# input curve: 0.500
@export var reduced_grip_curve: ProceduralCurve
@export var reduced_grip_limit_x_force: bool = true
@export var reduced_grip_apply_to_forces: bool = false
@export var reduced_grip_apply_to_torques: bool = false

@export_group("Force Conversion", "convert_")
@export var convert_forces: Array[StringName] = [
	&"engine",
	&"brake",
	&"coast_resistance",
	&"side_grip",
	&"boost_ground",
]

@export var convert_torques: Array[StringName] = [
	&"steer",
	&"angular_grip",
]

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		return

	var sum_of_forces: Vector3 = Vector3.ZERO
	for force in car.get_force_list():
		if convert_forces.has(force):
			sum_of_forces += car.get_force(force).force

	# TODO: add ability to only apply some of those conversions
	var reduced_grip: float = 1.0
	if reduced_grip_curve:
		reduced_grip = reduced_grip_curve.sample(abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).x))

	var converted_force: Vector3 = sum_of_forces
	if reduced_grip_limit_x_force:
		converted_force.x = clamp(converted_force.x, -grip_linear * reduced_grip, grip_linear * reduced_grip)
	converted_force = car.global_basis * converted_force
	converted_force = converted_force.slide(car.get_meta(&"ground_average_normal", Vector3.ZERO))

	var force_length_limit: float = grip_linear * car.get_meta(&"ground_coefficient", 0.0)
	if reduced_grip_apply_to_forces:
		force_length_limit *= reduced_grip
	converted_force = converted_force.limit_length(force_length_limit)

	car.set_force(&"converted_force", converted_force, false, car.get_meta(&"ground_average_point", Vector3.ZERO) - car.global_position)

	var sum_of_torques: Vector3 = Vector3.ZERO
	for torque in car.get_torque_list():
		if convert_torques.has(torque):
			sum_of_torques += car.get_torque(torque).torque

	var converted_torque: Vector3 = sum_of_torques
	converted_torque = car.global_basis * converted_torque
	converted_torque = converted_torque.project(car.get_meta(&"ground_average_normal", Vector3.ZERO))

	var torque_length_limit: float = grip_angular * car.get_meta(&"ground_coefficient", 0.0)
	if reduced_grip_apply_to_torques:
		torque_length_limit *= reduced_grip
	converted_torque = converted_torque.limit_length(torque_length_limit)

	car.set_torque(&"converted_torque", converted_torque)
