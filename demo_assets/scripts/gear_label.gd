extends Label

func get_gear_text(gear: int) -> String:
	var gear_text: String = str(gear)
	if gear_text == "0":
		gear_text = "N"
	if gear_text[0] == "-":
		gear_text = "R"
	return gear_text

func _process(_delta: float) -> void:
	var gear_text: String = get_gear_text(AACCGlobal.current_car.current_gear)
	if AACCGlobal.current_car.switching_gears:
		gear_text += " -> " + get_gear_text(AACCGlobal.current_car.target_gear)

	text = "Gear %s" % gear_text
