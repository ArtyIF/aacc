abstract class_name CarPluginBase extends Node3D

var car: Car
var plugin_deps: Dictionary[StringName, CarPluginBase]
var debuggable_properties: Array[StringName] = []

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

func update_plugin_deps(plugin_names: Array[StringName]) -> void:
	plugin_deps.clear()
	for plugin_name in plugin_names:
		plugin_deps[plugin_name] = car.get_plugin(plugin_name)

# key is the alias
# value is the actual name
func update_plugin_deps_aliased(plugin_names_map: Dictionary[StringName, StringName]) -> void:
	plugin_deps.clear()
	for plugin_name in plugin_names_map.keys():
		plugin_deps[plugin_name] = car.get_plugin(plugin_names_map[plugin_name])

func process_plugin(delta: float) -> void:
	pass
