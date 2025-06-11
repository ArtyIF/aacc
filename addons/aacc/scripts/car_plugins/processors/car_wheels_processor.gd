class_name CarWheelsProcessor extends CarPluginBase

@export_custom(PROPERTY_HINT_ARRAY_TYPE, "22/26:CarWheelSuspension") var wheels: Array[NodePath] = []

var wheels_total: int = 0
var wheels_landed: int = 0
var ground_coefficient: float = 0.0
var ground_coefficient_prev: float = 0.0
var ground_average_point: Vector3 = Vector3.ZERO
var ground_average_normal: Vector3 = Vector3.ZERO

var plugins_wheel: Array[CarWheelSuspension] = []

func _ready() -> void:
	for plugin in car.plugins.values():
		if plugin is CarWheelSuspension:
			plugins_wheel.append(plugin)
	wheels_total = len(plugins_wheel)

	car.plugin_added.connect(_on_plugin_added)
	car.plugin_removed.connect(_on_plugin_removed)

	debuggable_properties = [
		&"wheels_total",
		&"wheels_landed",
		&"ground_coefficient",
		&"ground_coefficient_prev",
		&"ground_average_point",
		&"ground_average_normal",
	]

func _on_plugin_added(plugin_name: StringName, plugin: CarPluginBase):
	if plugin is CarWheelSuspension:
		plugins_wheel.append(plugin)
		wheels_total = len(plugins_wheel)

func _on_plugin_removed(plugin_name: StringName, plugin: CarPluginBase):
	if plugin is CarWheelSuspension:
		plugins_wheel.erase(plugin)
		wheels_total = len(plugins_wheel)

func process_plugin(delta: float) -> void:
	ground_coefficient_prev = ground_coefficient

	wheels_landed = 0
	ground_coefficient = 0.0
	ground_average_point = Vector3.ZERO
	ground_average_normal = Vector3.ZERO

	for wheel: CarWheelSuspension in plugins_wheel:
		if wheel.is_landed:
			wheels_landed += 1
			ground_average_point += wheel.collision_point
			ground_average_normal += wheel.collision_normal

	if wheels_landed > 0:
		ground_coefficient = float(wheels_landed) / wheels_total
		ground_average_point /= wheels_landed
		ground_average_normal = ground_average_normal.normalized()
	else:
		ground_average_normal = Vector3.UP
