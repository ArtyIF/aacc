extends GeometryInstance3D

@export var sun: DirectionalLight3D
@export_range(0.0, 5.0) var flare_intensity: float = 1.0

var viewport: Viewport
var visibility_smooth: SmoothedFloat
@onready var occlusion_cast: RayCast3D = $OcclusionCast # TODO: take angle into account

func _process(delta: float) -> void:
	viewport = get_viewport()

	if not visibility_smooth:
		visibility_smooth = SmoothedFloat.new(0.0, 5.0)

	if not sun or not viewport: return

	var camera: Camera3D = viewport.get_camera_3d()
	var effective_sun_dir: Vector3 = sun.global_basis.z * max(camera.near, 1.0)
	effective_sun_dir += camera.global_position

	var visibility: float = 1.0 if camera.is_position_in_frustum(effective_sun_dir) else 0.0

	occlusion_cast.target_position = Vector3.FORWARD * camera.far
	occlusion_cast.look_at(effective_sun_dir)
	occlusion_cast.force_raycast_update()
	visibility *= 0.0 if occlusion_cast.is_colliding() else 1.0

	visibility_smooth.advance_to(visibility, delta)
	visible = visibility_smooth.get_value() > 0.0 and not camera.is_position_behind(effective_sun_dir)

	if visible:
		var unprojected_sun_dir: Vector2 = camera.unproject_position(effective_sun_dir) / Vector2(viewport.size)
		material_override.set_shader_parameter("sun_position", unprojected_sun_dir)
		material_override.set_shader_parameter("tint", Vector3(sun.light_color.r, sun.light_color.g, sun.light_color.b) * sun.light_energy)
	
		var tint_multiplier: float = clamp(remap(unprojected_sun_dir.distance_to(Vector2(0.5, 0.5)), 0.0, 0.5, 0.25, 1.0), 0.0, 1.0)
		tint_multiplier *= visibility_smooth.get_value()
		tint_multiplier *= flare_intensity
		material_override.set_shader_parameter("tint_multiplier", tint_multiplier)
