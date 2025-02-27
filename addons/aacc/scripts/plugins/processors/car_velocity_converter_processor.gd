class_name CarVelocityConverterProcessor extends CarPluginBase

@export var linear_grip: float = 40000.0

@export var forces_to_convert: Array[String] = [
	"Engine",
	"Brake",
	"SideGrip",
	"CoastResistance",
]

@export var torques_to_convert: Array[String] = [
	"TorqueGrip",
	"Steer",
]

func _ready() -> void:
	pass

func process_plugin(delta: float) -> void:
	var sum_of_forces: Vector3 = Vector3.ZERO
	for force in car.forces.keys():
		if forces_to_convert.has(force):
			sum_of_forces += car.pop_force(force).force

	if car.get_param("GroundCoefficient") > 0.0:
		var converted_force: Vector3 = sum_of_forces
		converted_force = car.global_basis * converted_force
		converted_force = Plane(car.get_param("GroundAverageNormal")).project(converted_force)
		converted_force = converted_force.limit_length(linear_grip)

		car.add_force("ConvertedForce", converted_force, car.get_param("GroundAveragePoint") - car.global_position)

	# TODO: torques
