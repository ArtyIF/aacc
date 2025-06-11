abstract class_name CarPluginBase extends Node3D

var car: Car

var debuggable_parameters: Array[StringName] = []

func _enter_tree() -> void:
	var car_parent = get_parent()
	while car_parent != null:
		if car_parent is Car:
			car = car_parent
			car.add_plugin(name, self)
			return
		else:
			car_parent = car_parent.get_parent()

	assert(false, "No car parent found for plugin " + str(get_path()))

func _exit_tree() -> void:
	if is_instance_valid(car):
		car.remove_plugin(name)

func process_plugin(delta: float) -> void:
	pass
