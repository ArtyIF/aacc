class_name Car extends RigidBody3D

# TODO: rewrite every plugin to just store parameters in their own object, no metas
# TODO for the repo: https://docs.codeberg.org/git/using-lfs

#region Forces
class Force:
	var force: Vector3 = Vector3.ZERO
	var position: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

var forces: Dictionary[StringName, Force] = {}

func set_force(force_name: StringName, force: Vector3, do_not_apply: bool = false, position: Vector3 = Vector3.ZERO):
	var new_force: Force = Force.new()
	new_force.force = force
	new_force.position = position
	new_force.do_not_apply = do_not_apply
	forces[force_name] = new_force

func get_force(force_name: StringName) -> Force:
	return forces.get(force_name, null)

func remove_force(force_name: StringName):
	forces.erase(force_name)

func get_force_list() -> Array[StringName]:
	return forces.keys()
#endregion Forces

#region Torques
class Torque:
	var torque: Vector3 = Vector3.ZERO
	var do_not_apply: bool = false

var torques: Dictionary[StringName, Torque] = {}

func set_torque(torque_name: StringName, torque: Vector3, do_not_apply: bool = false):
	var new_torque: Torque = Torque.new()
	new_torque.torque = torque
	new_torque.do_not_apply = do_not_apply
	torques[torque_name] = new_torque

func get_torque(torque_name: StringName) -> Torque:
	return torques.get(torque_name, null)

func remove_torque(torque_name: StringName):
	torques.erase(torque_name)

func get_torque_list() -> Array[StringName]:
	return torques.keys()
#endregion Torques

#region Plugins
var plugins: Dictionary[StringName, CarPluginBase] = {}
signal plugin_added(plugin_name: StringName, plugin: CarPluginBase)
signal plugin_removed(plugin_name: StringName, plugin: CarPluginBase)

func add_plugin(plugin_name: StringName, plugin: CarPluginBase):
	plugins[plugin_name] = plugin
	plugin_added.emit(plugin_name, plugin)

func get_plugin(plugin_name: StringName, default: CarPluginBase = null) -> CarPluginBase:
	return plugins.get(plugin_name, default)

func has_plugin(plugin_name: StringName) -> bool:
	return plugins.has(plugin_name)

func remove_plugin(plugin_name: StringName):
	var plugin: CarPluginBase = get_plugin(plugin_name)
	plugins.erase(plugin_name)
	plugin_removed.emit(plugin_name, plugin)
#endregion

func _physics_process(delta: float) -> void:
	if freeze:
		return
	
	if not forces.is_empty():
		forces.clear()
	if not torques.is_empty():
		torques.clear()

	# TODO: remove process_plugin and just use priority to make them run before
	# and figure out how to clear the forces and torques in a way it still
	# shows up in debug
	for plugin_name in plugins.keys():
		plugins[plugin_name].process_plugin(delta)

	for force_name in forces.keys():
		var force: Force = forces[force_name]
		if not force.do_not_apply:
			apply_force(force.force, force.position)

	for torque_name in torques.keys():
		var torque: Torque = torques[torque_name]
		if not torque.do_not_apply:
			apply_torque(torque.torque)
