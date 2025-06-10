class_name AACCDemoHUD extends ScenePluginBase

var plugin_lvp: CarLocalVelocityProcessor

func _process(_delta: float) -> void:
	if not is_instance_valid(car): return
	plugin_lvp = car.get_plugin(&"LocalVelocityProcessor")

	var gear_current: String = str(AACCGlobal.car.get_meta(&"gear_current", 0))
	if gear_current == "0":
		gear_current = "N"
	elif gear_current == "-1":
		gear_current = "R"
	if car.get_meta(&"gear_switching", false):
		gear_current = "-"

	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/Gear".text = gear_current.lpad(4, " ")
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/GearTransmission".text = "MT" if AACCGlobal.get_scene_plugin(&"CarInputEngineTransToggle").trans_manual else "AT"
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/TotalSpeed".text = str(roundi(car.linear_velocity.length() * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/ForwardSpeed".text = str(roundi(-plugin_lvp.local_velocity_linear.z * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/SideSpeed".text = str(roundi(plugin_lvp.local_velocity_linear.x * 3.6))

	$"HUDMargin/HUD/BoostPanel/VBox/BoostAmount".value = car.get_meta(&"boost_amount", 0.0)
