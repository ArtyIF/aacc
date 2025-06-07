class_name AACCDemoHUD extends ScenePluginBase

var car: Car

func _process(_delta: float) -> void:
	car = AACCGlobal.car
	if not car: return

	var gear_current: String = str(AACCGlobal.car.get_meta(&"gear_current", 0))
	if gear_current == "0":
		gear_current = "N"
	elif gear_current == "-1":
		gear_current = "R"
	if car.get_meta(&"gear_switching", false):
		gear_current = "-"

	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/Gear".text = gear_current.lpad(4, " ")
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/GearTransmission".text = "MANL" if AACCGlobal.get_plugin(&"CarInputEngineTransToggle").trans_manual else "AUTO"
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/TotalSpeed".text = str(roundi(AACCGlobal.car.linear_velocity.length() * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/ForwardSpeed".text = str(roundi(-AACCGlobal.car.get_meta(&"local_linear_velocity", Vector3.ZERO).z * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/SideSpeed".text = str(roundi(AACCGlobal.car.get_meta(&"local_linear_velocity", Vector3.ZERO).x * 3.6))

	$"HUDMargin/HUD/BoostPanel/VBox/BoostAmount".value = AACCGlobal.car.get_meta(&"boost_amount", 0.0)
