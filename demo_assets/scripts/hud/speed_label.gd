extends Control

func _process(_delta: float) -> void:
	var gear_current: String = str(AACCGlobal.car.get_meta(&"gear_current", 0))
	if gear_current == "0":
		gear_current = "N"
	elif gear_current == "-1":
		gear_current = "R"
	if AACCGlobal.car.get_meta(&"gear_switching", false):
		gear_current = "-"

	$"Gear".text = gear_current.lpad(4, " ")
	$"GearTransmission".text = "MANL" if AACCGlobal.get_plugin(&"CarInput").manual_transmission else "AUTO"
	if AACCGlobal.get_plugin(&"CarInput").launch_control_engaged:
		$"GearTransmission".text = "LNCH"
	$"TotalSpeed".text = str(roundi(AACCGlobal.car.linear_velocity.length() * 3.6))
	$"ForwardSpeed".text = str(roundi(-AACCGlobal.car.get_meta(&"local_linear_velocity", Vector3.ZERO).z * 3.6))
	$"SideSpeed".text = str(roundi(AACCGlobal.car.get_meta(&"local_linear_velocity", Vector3.ZERO).x * 3.6))
