class_name Car extends RigidBody3D

# TODO: add an editor tool to compile plugins into one script for optimization

#region Inputs
var inputs: Dictionary[StringName, float] = {}

func add_input(input_name: StringName, start_value: float = 0.0) -> bool:
	if inputs.has(input_name):
		return false

	inputs[input_name] = start_value
	return true

func get_input(input_name: StringName, default_value: float = 0.0) -> float:
	if inputs.has(input_name):
		return inputs[input_name]
	return default_value

func set_input(input_name: StringName, new_value: float) -> bool:
	if not inputs.has(input_name):
		return false
	inputs[input_name] = new_value
	return true

func add_or_get_input(input_name: StringName, start_value: float = 0.0) -> float:
	if not add_input(input_name, start_value):
		return get_input(input_name, start_value)
	return start_value

func add_or_set_input(input_name: StringName, new_value: float):
	if not set_input(input_name, new_value):
		add_input(input_name, new_value)

func remove_input(input_name: StringName) -> bool:
	if inputs.has(input_name):
		inputs.erase(input_name)
		return true
	return false
#endregion Inputs

#region Forces
class Force:
	var success: bool = true
	var force: Vector3 = Vector3.ZERO
	var position: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

	static func get_fail() -> Force:
		var force: Force = Force.new()
		force.success = false
		return force

var forces: Dictionary[StringName, Force] = {}

func add_force(force_name: StringName, force: Vector3, do_not_apply: bool = false, position: Vector3 = Vector3.ZERO) -> bool:
	if forces.has(force_name):
		return false

	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	new_force.do_not_apply = do_not_apply
	forces[force_name] = new_force

	return true

func get_force(force_name: StringName) -> Force:
	if not forces.has(force_name):
		return Force.get_fail()
	return forces[force_name]

func add_or_get_force(force_name: StringName, force: Vector3, position: Vector3 = Vector3.ZERO, do_not_apply: bool = false) -> Force:
	if not add_force(force_name, force, do_not_apply, position):
		return get_force(force_name)
	return get_force(force_name)

func pop_force(force_name: StringName) -> Force:
	var force: Force = get_force(force_name)
	if forces.has(force_name):
		forces.erase(force_name)
	return force
#endregion Forces

#region Torques
class Torque:
	var success: bool = true
	var torque: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

	static func get_fail() -> Torque:
		var torque: Torque = Torque.new()
		torque.success = false
		return torque

var torques: Dictionary[StringName, Torque] = {}

func add_torque(torque_name: StringName, torque: Vector3, do_not_apply: bool = false) -> bool:
	if torques.has(torque_name):
		return false

	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	new_torque.do_not_apply = do_not_apply
	torques[torque_name] = new_torque

	return true

func get_torque(torque_name: StringName) -> Torque:
	if not torques.has(torque_name):
		return Torque.get_fail()
	return torques[torque_name]

func add_or_get_torque(torque_name: StringName, torque: Vector3, do_not_apply: bool = false) -> Torque:
	if not add_torque(torque_name, torque, do_not_apply):
		return get_torque(torque_name)
	return get_torque(torque_name)

func pop_torque(torque_name: StringName) -> Torque:
	var torque: Torque = get_torque(torque_name)
	if torques.has(torque_name):
		torques.erase(torque_name)
	return torque
#endregion Torques

#region Params
# array is [name, group]
var params: Dictionary[Array, Variant] = {}

func add_param(param_name: StringName, start_value: Variant = null, param_group: StringName = "") -> bool:
	var param_key: Array[StringName] = [param_name, param_group]
	if params.has(param_key):
		return false
	params[param_key] = start_value
	return true

func get_param(param_name: StringName, default_value: Variant = null, param_group: StringName = "") -> Variant:
	var param_key: Array[StringName] = [param_name, param_group]
	if params.has(param_key):
		return params[param_key]
	print(param_name + " in group " + param_group + " not found")
	return default_value

func set_param(param_name: StringName, new_value: Variant, param_group: StringName = "") -> bool:
	var param_key: Array[StringName] = [param_name, param_group]
	if not params.has(param_key):
		print(param_name + " in group " + param_group + " not found")
		return false
	params[param_key] = new_value
	return true

func add_or_get_param(param_name: StringName, start_value: Variant = null, param_group: StringName = "") -> Variant:
	if not add_param(param_name, start_value, param_group):
		return get_param(param_name, start_value, param_group)
	return start_value

func add_or_set_param(param_name: StringName, new_value: Variant, param_group: StringName = ""):
	if not set_param(param_name, new_value, param_group):
		add_param(param_name, new_value, param_group)

func pop_param(param_name: StringName, param_group: StringName = "") -> Variant:
	var value: Variant = get_param(param_name, param_group)
	var param_key: Array[StringName] = [param_name, param_group]
	if params.has(param_key):
		params.erase(param_key)
	return value
#endregion Params

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
