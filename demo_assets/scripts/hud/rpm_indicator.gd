extends Control

var car: Car

var plugin_engine: CarEngine
var plugin_wp: CarWheelsProcessor

# TODO: move some of this stuff into demo HUD
func _ready() -> void:
	car = AACCGlobal.car
	AACCGlobal.car_changed.connect(_on_car_changed)

func _on_car_changed(new_car: Car):
	car = new_car
	if is_instance_valid(car):
		plugin_wp = car.get_plugin(&"WheelsProcessor")
		plugin_engine = car.get_plugin(&"Engine")

func remap_points(points: PackedVector2Array) -> PackedVector2Array:
	for i in range(len(points)):
		var point: Vector2 = points[i]
		points[i] = Vector2(point.x * size.x, (1.0 - point.y) * size.y)
	return points

func _draw() -> void:
	if not car: return

	var gear_perfect_shift_up: float = 1.0
	var gear_perfect_shift_down: float = 0.0

	var points_current: PackedVector2Array = []
	var points_next: PackedVector2Array = []
	var points_prev: PackedVector2Array = []
	if not plugin_engine.rpm_curve:
		draw_string(ThemeDB.fallback_font, Vector2(0.0, size.y), "No RPM curve!")
	else:
		var gear_current: float = float(plugin_engine.gear_current)
		points_current = remap_points(AACCCurveTools.get_curve_samples(plugin_engine.rpm_curve))

		if not plugin_engine.gear_switching:
			if plugin_wp.ground_coefficient > 0.0:
				if gear_current > 0 and gear_current < plugin_engine.gearbox_gear_count:
					var current_next_ratio: float = max(gear_current, 1.0) / max(gear_current + 1, 1.0)
					if current_next_ratio < 1.0:
						points_next = remap_points(AACCCurveTools.get_curve_samples(plugin_engine.rpm_curve, current_next_ratio))
					gear_perfect_shift_up = AACCCurveTools.get_gear_perfect_shift_up(plugin_engine)

				if gear_current > 1 and gear_current <= plugin_engine.gearbox_gear_count:
					var current_prev_ratio: float = max(gear_current, 1.0) / max(gear_current - 1, 1.0)
					if current_prev_ratio > 1.0:
						points_prev = remap_points(AACCCurveTools.get_curve_samples(plugin_engine.rpm_curve, current_prev_ratio))
					gear_perfect_shift_down = AACCCurveTools.get_gear_perfect_shift_down(plugin_engine)

	draw_rect(Rect2(0.0, 0.0, plugin_engine.rpm_max * size.x, 0.05 * size.y), Color.WHITE)
	draw_rect(Rect2(plugin_engine.rpm_max * size.x, 0.0, (1.0 - plugin_engine.rpm_max) * size.x, size.y), Color.RED)

	var rpm_ratio: float = plugin_engine.rpm_ratio.get_value()
	var rpm_bar_color: Color = Color.WHITE
	if rpm_ratio <= gear_perfect_shift_down:
		rpm_bar_color = Color.RED
	elif rpm_ratio >= gear_perfect_shift_up:
		rpm_bar_color = Color.GREEN
	draw_rect(Rect2(0.0, 0.05 * size.y, rpm_ratio * size.x, 0.95 * size.y), rpm_bar_color)

	if not points_prev.is_empty():
		draw_polyline(points_prev, Color.RED, 1.0, true)
	if not points_next.is_empty():
		draw_polyline(points_next, Color.GREEN, 1.0, true)
	if not points_current.is_empty():
		draw_polyline(points_current, Color.CYAN, 1.0, true)

func _process(_delta: float) -> void:
	queue_redraw()
