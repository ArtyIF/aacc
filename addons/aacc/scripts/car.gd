class_name Car extends RigidBody3D

# TODO: add an editor tool to compile plugins into one script for optimization

func meta_filter(value: String, prefix: String) -> bool:
	return value.begins_with(prefix)

#region Inputs
func set_input(input_name: String, new_value: float):
	set_meta("input_" + input_name, new_value)

func get_input(input_name: String, default_value: float = 0.0) -> float:
	return get_meta("input_" + input_name, default_value)

func remove_input(input_name: String):
	remove_meta("input_" + input_name)

func get_input_list() -> Array[String]:
	var list: Array[String] = []
	for meta in get_meta_list().filter(meta_filter.bind("input_")):
		list.append(meta.trim_prefix("input_"))
	return list
#endregion Inputs

#region Params
func set_param(param_name: String, new_value: Variant):
	set_meta("param_" + param_name, new_value)

func get_param(param_name: String, default_value: Variant = null) -> Variant:
	return get_meta("param_" + param_name, default_value)

func remove_param(param_name: String):
	remove_meta("param_" + param_name)

func get_param_list() -> Array[String]:
	var list: Array[String] = []
	for meta in get_meta_list().filter(meta_filter.bind("param_")):
		list.append(meta.trim_prefix("param_"))
	return list
#endregion Params

#region Forces
class Force:
	var force: Vector3 = Vector3.ZERO
	var position: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

var forces: Dictionary[String, Force] = {}

func set_force(force_name: String, force: Vector3, do_not_apply: bool = false, position: Vector3 = Vector3.ZERO):
	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	new_force.do_not_apply = do_not_apply
	forces.set(force_name, new_force)

func get_force(force_name: String) -> Force:
	return forces.get(force_name, null)

func remove_force(force_name: String):
	forces.erase(force_name)

func get_force_list() -> Array[String]:
	return forces.keys()
#endregion Forces

#region Torques
class Torque:
	var torque: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

var torques: Dictionary[String, Torque] = {}

func set_torque(torque_name: String, torque: Vector3, do_not_apply: bool = false):
	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	new_torque.do_not_apply = do_not_apply
	torques.set(torque_name, new_torque)

func get_torque(torque_name: String) -> Torque:
	return torques.get(torque_name, null)

func remove_torque(torque_name: String):
	torques.erase(torque_name)

func get_torque_list() -> Array[String]:
	return torques.keys()
#endregion Torques

#region Plugins
var plugins_list: Array[CarPluginBase] = []

func update_plugins():
	plugins_list.clear()
	for child in $"Plugins".get_children():
		if child is CarPluginBase:
			plugins_list.append(child)
#endregion Plugins

func _ready() -> void:
	update_plugins()

func _physics_process(delta: float) -> void:
	if freeze:
		return

	if not forces.is_empty():
		forces.clear()
	if not torques.is_empty():
		torques.clear()

	for plugin in plugins_list:
		plugin.process_plugin(delta)

	for force: Force in forces.values():
		if not force.do_not_apply:
			apply_force(force.force, force.position)

	for torque: Torque in torques.values():
		if not torque.do_not_apply:
			apply_torque(torque.torque)
