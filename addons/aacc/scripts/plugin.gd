class_name AACCPlugin extends Node

## The car that's a parent of the plugin. The plugin MUST be a direct child of
## the car!
@onready var parent_car: AACCCar = get_parent() as AACCCar

func convert_force(force: Vector3, project_plane: Vector3 = Vector3.ZERO) -> Vector3:
	var converted_force = parent_car.global_basis * force
	if project_plane != Vector3.ZERO:
		converted_force = Plane(project_plane).project(converted_force)
	return converted_force
