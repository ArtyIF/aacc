extends RichTextLabel

func _process(_delta: float) -> void:
	if not visible: return

	text = ""

	push_table(2)
	push_cell()
	append_text("Current Car")
	pop()
	push_cell()
	append_text(AACCGlobal.car.name)
	pop()
	pop()
	append_text("\n")

	push_table(2)
	push_cell()
	append_text("Inputs")
	pop()
	push_cell()
	append_text("Values")
	pop()
	for input: StringName in AACCGlobal.car.inputs.keys():
		push_cell()
		append_text(input)
		pop()
		push_cell()
		append_text(str(AACCGlobal.car.get_input(input)))
		pop()
	pop()
	append_text("\n")

	push_table(3)
	push_cell()
	append_text("Forces")
	pop()
	push_cell()
	append_text("Values")
	pop()
	push_cell()
	append_text("Offsets")
	pop()
	for force: StringName in AACCGlobal.car.forces.keys():
		push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			push_color(Color(Color.BLACK, 0.5))
		append_text(force)
		pop()
		if AACCGlobal.car.get_force(force).do_not_apply:
			pop()
		push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			push_color(Color(Color.BLACK, 0.5))
		append_text(str(AACCGlobal.car.get_force(force).force))
		if AACCGlobal.car.get_force(force).do_not_apply:
			pop()
		pop()
		push_cell()
		if AACCGlobal.car.get_force(force).do_not_apply:
			push_color(Color(Color.BLACK, 0.5))
		append_text(str(AACCGlobal.car.get_force(force).position))
		if AACCGlobal.car.get_force(force).do_not_apply:
			pop()
		pop()
	pop()
	append_text("\n")

	push_table(2)
	push_cell()
	append_text("Torques")
	pop()
	push_cell()
	append_text("Values")
	pop()
	for torque: StringName in AACCGlobal.car.torques.keys():
		push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			push_color(Color(Color.BLACK, 0.5))
		append_text(torque)
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			pop()
		pop()
		push_cell()
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			push_color(Color(Color.BLACK, 0.5))
		append_text(str(AACCGlobal.car.get_torque(torque).torque))
		if AACCGlobal.car.get_torque(torque).do_not_apply:
			pop()
		pop()
	pop()
	append_text("\n")

	push_table(3)
	push_cell()
	append_text("Params")
	pop()
	push_cell()
	append_text("Groups")
	pop()
	push_cell()
	append_text("Values")
	pop()
	for param: Array[StringName] in AACCGlobal.car.params.keys():
		push_cell()
		append_text(param[0])
		pop()
		push_cell()
		append_text(param[1])
		pop()
		push_cell()
		append_text(str(AACCGlobal.car.get_param(param[0], null, param[1])))
		pop()
	pop()
	append_text("\n")
	
	push_table(2)
	push_cell()
	append_text("Plugins")
	pop()
	push_cell()
	append_text("Types")
	pop()
	for plugin in AACCGlobal.car.plugins_list:
		push_cell()
		append_text(plugin.name)
		pop()
		push_cell()
		append_text(plugin.get_script().get_global_name())
		pop()
	pop()
