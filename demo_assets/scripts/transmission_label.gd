extends Label

func _process(_delta: float) -> void:
	# TODO: change AT to MT on manual transitions
	var current_gear: String = str(AACCGlobal.car.get_param("CurrentGear", 0))
	if current_gear == "0":
		current_gear = "N"
	elif current_gear == "-1":
		current_gear = "R"
	if AACCGlobal.car.get_param("GearSwitchTimer", -1.0) > 0.0:
		current_gear = "-"

	text = "AT %s" % current_gear
