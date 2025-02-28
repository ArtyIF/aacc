class_name CarForceConverterProcessor extends CarPluginBase

@export var linear_grip: float = 40000.0
@export var angular_grip: float = 20000.0

@export var forces_to_convert: Array[String] = [
	"Engine",
	"Brake",
	"SideGrip",
	"CoastResistance",
]

@export var torques_to_convert: Array[String] = [
	"Steer",
	"AngularGrip",
]

func _ready() -> void:
	pass

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var sum_of_forces: Vector3 = Vector3.ZERO
	for force in car.forces.keys():
		if forces_to_convert.has(force):
			sum_of_forces += car.get_force(force).force

	var converted_force: Vector3 = sum_of_forces
	converted_force = car.global_basis * converted_force
	converted_force = Plane(car.get_param("GroundAverageNormal")).project(converted_force)
	converted_force = converted_force.limit_length(linear_grip * car.get_param("GroundCoefficient"))
	#converted_force *= car.get_param("GroundCoefficient")

	car.add_force("ConvertedForce", converted_force, false, car.get_param("GroundAveragePoint") - car.global_position)

	var sum_of_torques: Vector3 = Vector3.ZERO
	for torque in car.torques.keys():
		if torques_to_convert.has(torque):
			sum_of_torques += car.get_torque(torque).torque

	var converted_torque: Vector3 = sum_of_torques
	converted_torque = car.global_basis * converted_torque
	converted_torque = converted_torque.project(car.get_param("GroundAverageNormal"))
	converted_torque = converted_torque.limit_length(angular_grip * car.get_param("GroundCoefficient"))
	#converted_torque *= car.get_param("GroundCoefficient")

	car.add_torque("ConvertedTorque", converted_torque)
