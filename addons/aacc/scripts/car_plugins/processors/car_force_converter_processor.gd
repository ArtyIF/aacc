class_name CarForceConverterProcessor extends CarPluginBase

@export var linear_grip: float = 40000.0
@export var angular_grip: float = 20000.0
# default:
# left value: 1.0
# right value: 0.5
# max input: 10.0
# input curve: 0.500
@export var reduced_grip_curve: ProceduralCurve
@export var limit_x_force: bool = true
@export var apply_reduced_grip_to_all_forces: bool = false
@export var apply_reduced_grip_to_torques: bool = false

@export var forces_to_convert: Array[String] = [
	"Engine",
	"Brake",
	"CoastResistance",
	"SideGrip",
	"Boost",
]

@export var torques_to_convert: Array[String] = [
	"Steer",
	"AngularGrip",
]

func _ready() -> void:
	pass

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("ground_coefficient")):
		return

	var sum_of_forces: Vector3 = Vector3.ZERO
	for force in car.forces.keys():
		if forces_to_convert.has(force):
			sum_of_forces += car.get_force(force).force

	var reduced_grip: float = 1.0
	if reduced_grip_curve:
		reduced_grip = reduced_grip_curve.sample(abs(car.get_param("local_linear_velocity").x))

	var converted_force: Vector3 = sum_of_forces
	if limit_x_force:
		converted_force.x = clamp(converted_force.x, -linear_grip * reduced_grip, linear_grip * reduced_grip)
	converted_force = car.global_basis * converted_force
	converted_force = converted_force.slide(car.get_param("ground_average_normal"))

	var force_length_limit: float = linear_grip * car.get_param("ground_coefficient")
	if apply_reduced_grip_to_all_forces:
		force_length_limit *= reduced_grip
	converted_force = converted_force.limit_length(force_length_limit)

	car.set_force("ConvertedForce", converted_force, false, car.get_param("ground_average_point") - car.global_position)

	var sum_of_torques: Vector3 = Vector3.ZERO
	for torque in car.torques.keys():
		if torques_to_convert.has(torque):
			sum_of_torques += car.get_torque(torque).torque

	var converted_torque: Vector3 = sum_of_torques
	converted_torque = car.global_basis * converted_torque
	converted_torque = converted_torque.project(car.get_param("ground_average_normal"))

	var torque_length_limit: float = angular_grip * car.get_param("ground_coefficient")
	if apply_reduced_grip_to_torques:
		torque_length_limit *= reduced_grip
	converted_torque = converted_torque.limit_length(torque_length_limit)

	car.set_torque("ConvertedTorque", converted_torque)
