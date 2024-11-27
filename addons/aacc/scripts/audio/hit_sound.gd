extends AudioStreamPlayer3D

func _physics_process(delta: float) -> void:
	if not playing:
		queue_free()
