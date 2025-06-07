class_name CarPluginBase extends Node3D

var car: Car

func _enter_tree() -> void:
	var car_parent = get_parent()
	while car_parent != null:
		if car_parent is Car:
			car = car_parent
			car.plugins[name] = self
			return
		else:
			car_parent = car_parent.get_parent()

	assert(false, "No car parent found for plugin " + str(get_path()))

func process_plugin(delta: float) -> void:
	pass
