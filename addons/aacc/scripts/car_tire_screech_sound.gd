## TODO: documentation
class_name CarTireScreechSound extends AudioStreamPlayer3D

@onready var car: Car = get_node("../..")
var smoothed_burnout_amount: SmoothedFloat = SmoothedFloat.new(0.0, 5.0)

func _process(delta: float) -> void:
	smoothed_burnout_amount.advance_to(car.burnout_amount, delta)
	volume_db = lerp(-40.0, 0.0, sqrt(smoothed_burnout_amount.get_current_value()))
	pitch_scale = lerp(0.5, 1.25, smoothed_burnout_amount.get_current_value())
	if volume_db > -40.0 and not playing:
		play()
	elif volume_db <= -40.0 and playing:
		stop()
