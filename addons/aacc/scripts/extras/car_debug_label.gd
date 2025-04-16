class_name CarDebugLabel extends ScenePluginBase

func _process(_delta: float) -> void:
	var label: RichTextLabel = $DebugLabelText

	if Input.is_action_just_pressed("aacc_debug_toggle"):
		label.visible = not label.visible

	if not label.visible: return

	label.text = ""
	
	label.push_table(2)
	label.push_cell()
	label.add_text("Scene Plugins")
	label.pop()
	label.push_cell()
	label.add_text("Type")
	label.pop()
	for plugin in AACCGlobal.scene_plugins.keys():
		label.push_cell()
		label.add_text(plugin)
		label.pop()
		label.push_cell()
		label.add_text(AACCGlobal.get_plugin(plugin).get_script().get_global_name())
		label.pop()
	label.pop()
	label.add_text("\n\n")

	label.push_table(2)
	label.push_cell()
	label.add_text("Current Car")
	label.pop()
	label.push_cell()
	label.add_text(AACCGlobal.car.name)
	label.pop()
	label.pop()
	label.add_text("\n\n")
	
	label.push_table(2)
	label.push_cell()
	label.add_text("Car Plugins")
	label.pop()
	label.push_cell()
	label.add_text("Type")
	label.pop()
	for plugin in AACCGlobal.car.plugins_list:
		label.push_cell()
		label.add_text(plugin.name)
		label.pop()
		label.push_cell()
		label.add_text(plugin.get_script().get_global_name())
		label.pop()
	label.pop()
	label.add_text("\n\n")

	label.push_table(2)
	label.push_cell()
	label.add_text("Metadata")
	label.pop()
	label.push_cell()
	label.add_text("Value")
	label.pop()
	for meta: StringName in AACCGlobal.car.get_meta_list():
		label.push_cell()
		label.add_text(meta)
		label.pop()
		label.push_cell()
		label.add_text(str(AACCGlobal.car.get_meta(meta)))
		label.pop()
	label.pop()
	label.add_text("\n\n")

	label.push_table(3)
	label.push_cell()
	label.add_text("Forces")
	label.pop()
	label.push_cell()
	label.add_text("Value")
	label.pop()
	label.push_cell()
	label.add_text("Offset")
	label.pop()
	for force: String in AACCGlobal.car.get_force_list():
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.add_text(force)
		label.pop()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.add_text(str(AACCGlobal.car.get_force(force).force))
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.pop()
		label.push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.add_text(str(AACCGlobal.car.get_force(force).position))
		if AACCGlobal.car.get_force(force).do_not_apply:
			label.pop()
		label.pop()
	label.pop()
	label.add_text("\n\n")

	label.push_table(2)
	label.push_cell()
	label.add_text("Torques")
	label.pop()
	label.push_cell()
	label.add_text("Value")
	label.pop()
	for torque: String in AACCGlobal.car.get_torque_list():
		label.push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.add_text(torque)
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.pop()
		label.pop()
		label.push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.push_color(Color(Color.BLACK, 0.5))
		label.add_text(str(AACCGlobal.car.get_torque(torque).torque))
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			label.pop()
		label.pop()
	label.pop()
	label.add_text("\n\n")
