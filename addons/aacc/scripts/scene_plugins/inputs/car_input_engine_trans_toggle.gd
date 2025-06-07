class_name CarInputEngineTransToggle extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_trans_toggle: StringName = &"aacc_trans_toggle"

@export_group("Engine Plugins", "engine_plugin_")
@export var engine_plugin_auto: CarInputEngineAuto
@export var engine_plugin_manual: CarInputEngineManual

var car: Car
var trans_manual: bool = false

func _physics_process(delta: float) -> void:
	car = AACCGlobal.car
	if not car: return

	if Input.is_action_just_pressed(action_trans_toggle):
		trans_manual = not trans_manual
		if trans_manual:
			engine_plugin_manual.gear_target = engine_plugin_auto.gear_target
		else:
			engine_plugin_auto.gear_target = engine_plugin_manual.gear_target

	engine_plugin_auto.process_mode = PROCESS_MODE_DISABLED if trans_manual else PROCESS_MODE_INHERIT
	engine_plugin_manual.process_mode = PROCESS_MODE_INHERIT if trans_manual else PROCESS_MODE_DISABLED
