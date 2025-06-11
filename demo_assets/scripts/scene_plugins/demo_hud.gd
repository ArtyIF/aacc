class_name AACCDemoHUD extends ScenePluginBase

var plugin_lvp: CarLocalVelocityProcessor
var plugin_wp: CarWheelsProcessor
var plugin_engine: CarEngine

func _on_car_changed(new_car: Car) -> void:
	super(new_car)
	if is_instance_valid(car):
		plugin_lvp = car.get_plugin(&"LocalVelocityProcessor")
		plugin_wp = car.get_plugin(&"WheelsProcessor")
		plugin_engine = car.get_plugin(&"Engine")

func _process(_delta: float) -> void:
	if not is_instance_valid(car): return

	var gear_current: String = str(AACCGlobal.car.get_meta(&"gear_current", 0))
	if gear_current == "0":
		gear_current = "N"
	elif gear_current == "-1":
		gear_current = "R"
	if car.get_meta(&"gear_switching", false):
		gear_current = "-"

	var rpm_indicator: AACCDemoRPMIndicator = $"HUDMargin/HUD/SpeedPanel/VBox/RPMIndicator"
	rpm_indicator.ground_coefficient = plugin_wp.ground_coefficient
	rpm_indicator.rpm_curve = plugin_engine.rpm_curve
	rpm_indicator.rpm_max = plugin_engine.rpm_max
	rpm_indicator.rpm_ratio = plugin_engine.rpm_ratio.get_value()
	rpm_indicator.gear_count = plugin_engine.gearbox_gear_count
	rpm_indicator.gear_current = plugin_engine.gear_current
	rpm_indicator.gear_switching = plugin_engine.gear_switching

	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/Gear".text = gear_current.lpad(4, " ")
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/GearTransmission".text = "MT" if AACCGlobal.get_scene_plugin(&"CarInputEngineTransToggle").trans_manual else "AT"
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/TotalSpeed".text = str(roundi(car.linear_velocity.length() * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/ForwardSpeed".text = str(roundi(-plugin_lvp.local_velocity_linear.z * 3.6))
	$"HUDMargin/HUD/SpeedPanel/VBox/SpeedContainer/SideSpeed".text = str(roundi(plugin_lvp.local_velocity_linear.x * 3.6))

	$"HUDMargin/HUD/BoostPanel/VBox/BoostAmount".value = car.get_meta(&"boost_amount", 0.0)
