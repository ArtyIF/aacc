class_name Car extends RigidBody3D

var inputs: Dictionary[StringName, float] = {}

func add_input(input_name: StringName, default_value: float = 0.0) -> bool:
	if inputs.has(input_name):
		return false

	inputs[input_name] = default_value
	return true

func get_input(input_name: StringName, default_value: float = 0.0) -> float:
	if inputs.has(input_name):
		return inputs[input_name]
	return default_value

func add_or_get_input(input_name: StringName, default_value: float = 0.0) -> float:
	if not add_input(input_name, default_value):
		return get_input(input_name, default_value)
	return default_value

func set_input(input_name: StringName, new_value: float) -> bool:
	if not inputs.has(input_name):
		return false
	inputs[input_name] = new_value
	return true

class Force:
	var success: bool = true
	var force: Vector3 = Vector3.ZERO
	var position: Vector3 = Vector3.ZERO
	var is_impulse: bool = false

	static func get_fail() -> Force:
		var force: Force = Force.new()
		force.success = false
		return force

var forces: Dictionary[StringName, Force] = {}

func add_force(force_name: StringName, force: Vector3, position: Vector3 = Vector3.ZERO, is_impulse: bool = false) -> bool:
	if forces.has(force_name):
		return false

	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	new_force.is_impulse = is_impulse
	forces[force_name] = new_force

	return true

func get_force(force_name: StringName) -> Force:
	if not forces.has(force_name):
		return Force.get_fail()
	return forces[force_name]

func add_or_get_force(force_name: StringName, force: Vector3, position: Vector3 = Vector3.ZERO, is_impulse: bool = false) -> Force:
	if not add_force(force_name, force, position, is_impulse):
		return get_force(force_name)
	return get_force(force_name)

func pop_force(force_name: StringName) -> Force:
	var force: Force = get_force(force_name)
	if forces.has(force_name):
		forces.erase(force_name)
	return force

class Torque:
	var success: bool = true
	var torque: Vector3 = Vector3.ZERO
	var is_impulse: bool = false

	static func get_fail() -> Torque:
		var torque: Torque = Torque.new()
		torque.success = false
		return torque

var torques: Dictionary[StringName, Torque] = {}

func add_torque(torque_name: StringName, torque: Vector3, is_impulse: bool = false) -> bool:
	if torques.has(torque_name):
		return false

	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	new_torque.is_impulse = is_impulse
	torques[torque_name] = new_torque

	return true

func get_torque(torque_name: StringName) -> Torque:
	if not torques.has(torque_name):
		return Torque.get_fail()
	return torques[torque_name]

func add_or_get_torque(torque_name: StringName, torque: Vector3, is_impulse: bool = false) -> Torque:
	if not add_torque(torque_name, torque, is_impulse):
		return get_torque(torque_name)
	return get_torque(torque_name)

func pop_torque(torque_name: StringName) -> Torque:
	var torque: Torque = get_torque(torque_name)
	if torques.has(torque_name):
		torques.erase(torque_name)
	return torque

func _physics_process(delta: float) -> void:
	# TODO: cache
	for child in get_children():
		if child is AACCPluginBase:
			child.process_plugin(delta)

	for force in forces.values():
		if force.is_impulse:
			apply_impulse(force.force, force.position)
		else:
			apply_force(force.force, force.position)
	forces.clear()

	for torque in torques.values():
		if torque.is_impulse:
			apply_torque_impulse(torque.torque)
		else:
			apply_torque(torque.torque)
	torques.clear()
