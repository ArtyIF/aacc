extends Label

func _process(_delta: float) -> void:
	text = "%d km/h" % floor(AACCGlobal.car.linear_velocity.length() * 3.6)
