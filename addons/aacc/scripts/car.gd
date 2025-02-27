class_name Car extends RigidBody3D

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

	static func get_fail() -> Force:
		var force: Force = Force.new()
		force.success = false
		return force

var forces: Dictionary[StringName, Force] = {}

func add_force(force_name: StringName, force: Vector3, position: Vector3 = Vector3.ZERO) -> bool:
	if forces.has(force_name):
		return false

	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	forces[force_name] = new_force

	return true

func get_force(force_name: StringName) -> Force:
	if not forces.has(force_name):
		return Force.get_fail()
	return forces[force_name]

func add_or_get_force(force_name: StringName, force: Vector3, position: Vector3 = Vector3.ZERO) -> Force:
	if not add_force(force_name, force, position):
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

	static func get_fail() -> Torque:
		var torque: Torque = Torque.new()
		torque.success = false
		return torque

var torques: Dictionary[StringName, Torque] = {}

func add_torque(torque_name: StringName, torque: Vector3) -> bool:
	if torques.has(torque_name):
		return false

	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	torques[torque_name] = new_torque

	return true

func get_torque(torque_name: StringName) -> Torque:
	if not torques.has(torque_name):
		return Torque.get_fail()
	return torques[torque_name]

func add_or_get_torque(torque_name: StringName, torque: Vector3) -> Torque:
	if not add_torque(torque_name, torque):
		return get_torque(torque_name)
	return get_torque(torque_name)

func pop_torque(torque_name: StringName) -> Torque:
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

var params: Dictionary[StringName, Param] = {}

func add_param(param_name: StringName, start_value: Variant = null) -> bool:
	if params.has(param_name):
		return false

	var new_param: Param = Param.new()
	new_param.value = start_value
	params[param_name] = new_param
	return true

func get_param(param_name: StringName, default_value: Variant = null) -> Variant:
	if params.has(param_name):
		return params[param_name].value
	return default_value

func set_param(param_name: StringName, new_value: Variant) -> bool:
	if not params.has(param_name):
		return false
	params[param_name].value = new_value
	return true

func add_or_get_param(param_name: StringName, start_value: Variant = null) -> Variant:
	if not add_param(param_name, start_value):
		return get_param(param_name, start_value)
	return start_value

func add_or_set_param(param_name: StringName, new_value: Variant):
	if not set_param(param_name, new_value):
		add_param(param_name, new_value)

func remove_param(param_name: StringName) -> bool:
	if params.has(param_name):
		params.erase(param_name)
		return true
	return false

func set_param_reset_value(param_name: StringName, reset_value: Variant):
	params[param_name].reset_value = reset_value

# TODO: methods for appending/removing?
#endregion Params

func _physics_process(delta: float) -> void:
	# TODO: cache
	for child in get_children():
		if child is AACCPluginBase:
			child.process_plugin(delta)

	for force in forces.values():
		apply_force(force.force, force.position)
	forces.clear()

	for torque in torques.values():
		apply_torque(torque.torque)
	torques.clear()
	
	for param_name in params.keys():
		if params[param_name].reset_value != null:
			params[param_name].value = params[param_name].reset_value
