class_name Car extends RigidBody3D

#region Inputs
var inputs: Dictionary[String, float] = {}

func add_input(input_name: String, start_value: float = 0.0) -> bool:
	if inputs.has(input_name):
		return false

	inputs[input_name] = start_value
	return true

func get_input(input_name: String, default_value: float = 0.0) -> float:
	if inputs.has(input_name):
		return inputs[input_name]
	return default_value

func set_input(input_name: String, new_value: float) -> bool:
	if not inputs.has(input_name):
		return false
	inputs[input_name] = new_value
	return true

func add_or_get_input(input_name: String, start_value: float = 0.0) -> float:
	if not add_input(input_name, start_value):
		return get_input(input_name, start_value)
	return start_value

func add_or_set_input(input_name: String, new_value: float):
	if not set_input(input_name, new_value):
		add_input(input_name, new_value)

func remove_input(input_name: String) -> bool:
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

var forces: Dictionary[String, Force] = {}

func add_force(force_name: String, force: Vector3, do_not_apply: bool = false, position: Vector3 = Vector3.ZERO) -> bool:
	if forces.has(force_name):
		return false

	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	new_force.do_not_apply = do_not_apply
	forces[force_name] = new_force

	return true

func get_force(force_name: String) -> Force:
	if not forces.has(force_name):
		return Force.get_fail()
	return forces[force_name]

func add_or_get_force(force_name: String, force: Vector3, position: Vector3 = Vector3.ZERO, do_not_apply: bool = false) -> Force:
	if not add_force(force_name, force, do_not_apply, position):
		return get_force(force_name)
	return get_force(force_name)

func pop_force(force_name: String) -> Force:
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

var torques: Dictionary[String, Torque] = {}

func add_torque(torque_name: String, torque: Vector3, do_not_apply: bool = false) -> bool:
	if torques.has(torque_name):
		return false

	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	new_torque.do_not_apply = do_not_apply
	torques[torque_name] = new_torque

	return true

func get_torque(torque_name: String) -> Torque:
	if not torques.has(torque_name):
		return Torque.get_fail()
	return torques[torque_name]

func add_or_get_torque(torque_name: String, torque: Vector3, do_not_apply: bool = false) -> Torque:
	if not add_torque(torque_name, torque, do_not_apply):
		return get_torque(torque_name)
	return get_torque(torque_name)

func pop_torque(torque_name: String) -> Torque:
	var torque: Torque = get_torque(torque_name)
	if torques.has(torque_name):
		torques.erase(torque_name)
	return torque
#endregion Torques

#region Params
class Param:
	var success: bool = true
	var value: Variant
	var reset_value: Variant

	static func get_fail() -> Param:
		var param: Param = Param.new()
		param.success = false
		return param

var params: Dictionary[String, Param] = {}

func add_param(param_name: String, start_value: Variant = null, start_value_is_reset_value: bool = false) -> bool:
	if params.has(param_name):
		return false

	var new_param: Param = Param.new()
	new_param.value = start_value
	if start_value_is_reset_value:
		new_param.reset_value = start_value
	params[param_name] = new_param
	return true

func get_param(param_name: String, default_value: Variant = null) -> Variant:
	if params.has(param_name):
		return params[param_name].value
	return default_value

func set_param(param_name: String, new_value: Variant) -> bool:
	if not params.has(param_name):
		return false
	params[param_name].value = new_value
	return true

func add_or_get_param(param_name: String, start_value: Variant = null, start_value_is_reset_value: bool = false) -> Variant:
	if not add_param(param_name, start_value, start_value_is_reset_value):
		return get_param(param_name, start_value)
	return start_value

func add_or_set_param(param_name: String, new_value: Variant, start_value_is_reset_value: bool = false):
	if not set_param(param_name, new_value):
		add_param(param_name, new_value, start_value_is_reset_value)

func pop_param(param_name: String) -> Variant:
	var value: Variant = get_param(param_name)
	if params.has(param_name):
		params.erase(param_name)
	return value

func set_param_reset_value(param_name: String, reset_value: Variant):
	params[param_name].reset_value = reset_value
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
	forces.clear()
	torques.clear()
	for param_name in params.keys():
		if params[param_name].reset_value != null:
			params[param_name].value = params[param_name].reset_value

	for plugin in plugins_list:
		plugin.process_plugin(delta)

	for force: Force in forces.values():
		if not force.do_not_apply:
			apply_force(force.force, force.position)

	for torque: Torque in torques.values():
		if not torque.do_not_apply:
			apply_torque(torque.torque)
