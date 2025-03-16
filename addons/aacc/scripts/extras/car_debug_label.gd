class_name CarDebugLabel extends ScenePluginBase

func _process(_delta: float) -> void:
	var label: RichTextLabel = $DebugLabelText

	if Input.is_action_just_pressed("aacc_debug_toggle"):
		label.visible = not label.visible

	if not label.visible: return

	label.text = ""
	
	label.push_table(2)
	label.push_cell()
	label.append_text("Scene Plugins")
	label.pop()
	label.push_cell()
	label.append_text("Types")
	label.pop()
	for plugin in AACCGlobal.scene_plugins.keys():
		label.push_cell()
		label.append_text(plugin)
		label.pop()
		label.push_cell()
		label.append_text(AACCGlobal.get_plugin(plugin).get_script().get_global_name())
		label.pop()
	label.pop()
	label.append_text("\n")

	label.push_table(2)
	label.push_cell()
	label.append_text("Current Car")
	label.pop()
	label.push_cell()
	label.append_text(AACCGlobal.car.name)
	label.pop()
	label.pop()
	label.append_text("\n")
	
	label.push_table(2)
	label.push_cell()
	label.append_text("Car Plugins")
	label.pop()
	label.push_cell()
	label.append_text("Types")
	label.pop()
	for plugin in AACCGlobal.car.plugins_list:
		label.push_cell()
		label.append_text(plugin.name)
		label.pop()
		label.push_cell()
		label.append_text(plugin.get_script().get_global_name())
		label.pop()
	label.pop()
	label.append_text("\n")

	label.push_table(2)
	label.push_cell()
	label.append_text("Params")
	label.pop()
	label.push_cell()
	label.append_text("Values")
	label.pop()
	for param: StringName in AACCGlobal.car.get_meta_list():
		label.push_cell()
		label.append_text(param)
		label.pop()
		label.push_cell()
		label.append_text(str(AACCGlobal.car.get_param(param, null)))
		label.pop()
	label.pop()
	label.append_text("\n")

	label.push_table(3)
	label.push_cell()
	label.append_text("Forces")
	label.pop()
	label.push_cell()
	label.append_text("Values")
	label.pop()
	label.push_cell()
	label.append_text("Offsets")
	label.pop()
	for force: String in AACCGlobal.car.get_force_list():
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.append_text(force)
		label.pop()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.append_text(str(AACCGlobal.car.get_force(force).force))
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.pop()
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.append_text(str(AACCGlobal.car.get_force(force).position))
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.pop()
	label.pop()
	label.append_text("\n")

	label.push_table(2)
	label.push_cell()
	label.append_text("Torques")
	label.pop()
	label.push_cell()
	label.append_text("Values")
	label.pop()
	for torque: String in AACCGlobal.car.get_torque_list():
		label.push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.append_text(torque)
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.pop()
		label.pop()
		label.push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.append_text(str(AACCGlobal.car.get_torque(torque).torque))
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.pop()
		label.pop()
	label.pop()
	label.append_text("\n")
