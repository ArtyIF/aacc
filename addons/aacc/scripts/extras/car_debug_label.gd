class_name CarDebugLabel extends ScenePluginBase

func _process(_delta: float) -> void:
	var label: RichTextLabel = $DebugLabelText

	if Input.is_action_just_pressed("aacc_debug_toggle"):
		label.visible = not label.visible

	if not label.visible: return

	label.text = ""

	label.push_bgcolor(Color.BLACK)
	label.add_text("SCENE PLUGINS\n")
	label.pop()

	label.push_table(2)
	label.push_cell()
	label.add_text("NAME")
	label.pop()
	label.push_cell()
	label.add_text("TYPE")
	label.pop()
	for plugin in AACCGlobal.scene_plugins.keys():
		label.push_cell()
		label.add_text(plugin)
		label.pop()
		label.push_cell()
		label.add_text(AACCGlobal.get_scene_plugin(plugin).get_script().get_global_name())
		label.pop()
	label.pop()
	label.add_text("\n\n")

	if is_instance_valid(AACCGlobal.car):
		label.push_bgcolor(Color.BLACK)
		label.add_text("CURRENT CARS\n")
		label.pop()

		label.push_table(2)
		label.push_cell()
		label.add_text("CAR 0")
		label.pop()
		label.push_cell()
		label.add_text(AACCGlobal.car.name)
		label.pop()
		label.pop()
		label.add_text("\n\n")
	else:
		label.push_bgcolor(Color.BLACK)
		label.add_text("NO CARS FOUND\n\n")
		label.pop()

	if is_instance_valid(AACCGlobal.car):
		label.push_bgcolor(Color.BLACK)
		label.add_text("CAR PLUGINS\n")
		label.pop()

		label.push_table(2)
		label.push_cell()
		label.add_text("NAME")
		label.pop()
		label.push_cell()
		label.add_text("TYPE")
		label.pop()
		for plugin_name in AACCGlobal.car.plugins.keys():
			label.push_cell()
			label.add_text(plugin_name)
			label.pop()
			label.push_cell()
			label.add_text(AACCGlobal.car.plugins[plugin_name].get_script().get_global_name())
			label.pop()
		label.pop()
		label.add_text("\n\n")

		for plugin_name in AACCGlobal.car.plugins.keys():
			var plugin_parameters: Dictionary[StringName, String] = {}
			for parameter_name in AACCGlobal.car.plugins[plugin_name].debuggable_parameters:
				plugin_parameters[parameter_name] = str(AACCGlobal.car.plugins[plugin_name].get(parameter_name))
			if plugin_parameters.is_empty():
				continue

			# TODO: include properties

			label.push_bgcolor(Color.BLACK)
			label.add_text("PLUGIN PARAMETERS: " + plugin_name + "\n")
			label.pop()

			label.push_table(2)
			label.push_cell()
			label.add_text("NAME")
			label.pop()
			label.push_cell()
			label.add_text("VALUE")
			label.pop()
			for parameter_name in plugin_parameters.keys():
				label.push_cell()
				label.add_text(parameter_name)
				label.pop()
				label.push_cell()
				label.add_text(plugin_parameters[parameter_name])
				label.pop()
			label.pop()
			label.add_text("\n\n")

		label.push_bgcolor(Color.BLACK)
		label.add_text("FORCES\n")
		label.pop()

		label.push_table(3)
		label.push_cell()
		label.add_text("NAME")
		label.pop()
		label.push_cell()
		label.add_text("VALUE")
		label.pop()
		label.push_cell()
		label.add_text("OFFSET")
		label.pop()
		for force: String in AACCGlobal.car.get_force_list():
			label.push_cell()
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.push_color(Color(Color.WHITE, 0.5))
			label.add_text(force)
			label.pop()
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.pop()
			label.push_cell()
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.push_color(Color(Color.WHITE, 0.5))
			label.add_text(str(AACCGlobal.car.get_force(force).force))
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.pop()
			label.pop()
			label.push_cell()
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.push_color(Color(Color.WHITE, 0.5))
			label.add_text(str(AACCGlobal.car.get_force(force).position))
			if AACCGlobal.car.get_force(force).do_not_apply:
				label.pop()
			label.pop()
		label.pop()
		label.add_text("\n\n")

		label.push_bgcolor(Color.BLACK)
		label.add_text("TORQUES\n")
		label.pop()

		label.push_table(2)
		label.push_cell()
		label.add_text("NAME")
		label.pop()
		label.push_cell()
		label.add_text("VALUE")
		label.pop()
		for torque: String in AACCGlobal.car.get_torque_list():
			label.push_cell()
			if AACCGlobal.car.get_torque(torque).do_not_apply:
				label.push_color(Color(Color.WHITE, 0.5))
			label.add_text(torque)
			if AACCGlobal.car.get_torque(torque).do_not_apply:
				label.pop()
			label.pop()
			label.push_cell()
			if AACCGlobal.car.get_torque(torque).do_not_apply:
				label.push_color(Color(Color.WHITE, 0.5))
			label.add_text(str(AACCGlobal.car.get_torque(torque).torque))
			if AACCGlobal.car.get_torque(torque).do_not_apply:
				label.pop()
			label.pop()
		label.pop()
		label.add_text("\n\n")

	label.push_bgcolor(Color.BLACK)
	label.add_text("PRESS aacc_debug_toggle TO CLOSE")
	label.pop()
