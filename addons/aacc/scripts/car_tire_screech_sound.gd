## TODO: documentation
class_name CarTireScreechSound extends AudioStreamPlayer3D

@onready var car: Car = get_node("..")
var smoothed_burnout_amount: SmoothedFloat = SmoothedFloat.new(0.0, 5.0)

func _process(delta: float) -> void:
	smoothed_burnout_amount.advance_to(car.burnout_amount, delta)
	volume_db = linear_to_db(smoothed_burnout_amount.get_current_value())
	if is_inf(volume_db):
		volume_db = -80.0
	pitch_scale = lerp(0.5, 1.25, smoothed_burnout_amount.get_current_value())
	if volume_db > -60.0 and not playing:
		play()
	elif volume_db <= -60.0 and playing:
		stop()
