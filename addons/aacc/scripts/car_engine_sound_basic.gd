## TODO: documentation
class_name CarEngineSoundBasic extends AudioStreamPlayer3D
@export var engine_pitch_range: Vector2 = Vector2(0.0, 1.0)
@export_range(-80.0, 0.0) var min_db: float = -15.0

@onready var car: Car = get_node("../..")

func _process(delta: float) -> void:
	volume_db = lerp(min_db, 0.0, car.accel_amount.get_current_value())
	pitch_scale = lerp(engine_pitch_range.x, engine_pitch_range.y, car.revs.get_current_value())
