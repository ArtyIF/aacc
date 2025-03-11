extends Control

func _process(_delta: float) -> void:
	var current_gear: String = str(AACCGlobal.car.get_param("CurrentGear", 0))
	if current_gear == "0":
		current_gear = "N"
	elif current_gear == "-1":
		current_gear = "R"
	if AACCGlobal.car.get_param("GearSwitchTimer", -1.0) > 0.0:
		current_gear = "-"

	$"Gear".text = current_gear.lpad(4, " ")
	$"GearTransmission".text = "MANL" if AACCGlobal.get_plugin("CarInput").manual_transmission else "AUTO"
	$"TotalSpeed".text = str(roundi(AACCGlobal.car.linear_velocity.length() * 3.6))
	$"ForwardSpeed".text = str(roundi(-AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).z * 3.6))
	$"SideSpeed".text = str(roundi(AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).x * 3.6))
