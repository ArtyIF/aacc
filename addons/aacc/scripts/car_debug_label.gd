extends Label

func _physics_process(_delta: float) -> void:
	var result_text: String = ""
	result_text += "Current car: " + AACCGlobal.car.name + "\n"
	result_text += "\n"

	result_text += "Inputs:\n"
	for input: String in AACCGlobal.car.inputs.keys():
		result_text += input + " = " + str(AACCGlobal.car.get_input(input)) + "\n"
	result_text += "\n"

	result_text += "Forces:\n"
	for force: String in AACCGlobal.car.forces.keys():
		result_text += force + " = " + str(AACCGlobal.car.get_force(force).force) + "\n"
	result_text += "\n"

	result_text += "Torques:\n"
	for torque: String in AACCGlobal.car.torques.keys():
		result_text += torque + " = " + str(AACCGlobal.car.get_torque(torque).torque) + "\n"
	result_text += "\n"

	result_text += "Params:\n"
	for param: String in AACCGlobal.car.params.keys():
		result_text += param + " = " + str(AACCGlobal.car.get_param(param)) + "\n"

	text = result_text
