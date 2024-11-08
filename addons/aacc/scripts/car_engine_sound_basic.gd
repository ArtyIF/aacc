## TODO: documentation
class_name CarEngineSoundBasic extends AudioStreamPlayer3D
@export var engine_pitch_range: Vector2 = Vector2(0.0, 1.0)
@export_range(0.0, 1.0) var min_volume: float = 0.1

@onready var car: Car = get_node("..")

func _ready() -> void:
	volume_db = linear_to_db(min_volume)
	pitch_scale = engine_pitch_range.x

func _process(delta: float) -> void:
	volume_db = linear_to_db(lerp(min_volume, 1.0, car.accel_amount.get_current_value()))
	pitch_scale = lerp(engine_pitch_range.x, engine_pitch_range.y, car.revs.get_current_value())
