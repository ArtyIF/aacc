## TODO: documentation
class_name CarTireScreechSound extends AudioStreamPlayer3D
@export var pitch_range: Vector2 = Vector2(0.5, 1.0)

@onready var car: Car = get_node("..")

func _physics_process(_delta: float) -> void:
	pitch_scale = lerp(pitch_range.x, pitch_range.y, car.burnout_amount)
	volume_db = linear_to_db(car.burnout_amount)

	if is_inf(volume_db):
		volume_db = -80.0
	if volume_db >= -60.0 and not playing:
		play(randf_range(0.0, stream.get_length()))
	elif volume_db < -60.0 and playing:
		stop()
