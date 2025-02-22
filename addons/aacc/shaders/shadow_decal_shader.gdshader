// Based on the shader at https://godotshaders.com/shader/decal-example/
// written by TwistedTwigleg and published under the MIT license

shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_front, depth_test_disabled, blend_mix, fog_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear;
#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
	uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;
#endif

uniform sampler2D shadow_texture : source_color, hint_default_black, repeat_disable, filter_linear_mipmap_anisotropic;
uniform int shadow_texture_mipmaps = 9;

uniform float shadow_size = 4.0;
uniform float shadow_height_above = 0.25;
uniform float shadow_height_below = 1.25;
uniform float shadow_intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec2 shadow_range = vec2(0.0, 1.0);

varying mat4 INV_MODEL_MATRIX;

void vertex() {
	INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
}

// Credit: https://stackoverflow.com/questions/32227283/getting-world-position-from-depth-buffer-value
vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view) {
	float z = depth;
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
		z *= 2.0;
		z -= 1.0;
	#endif
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	return worldSpacePosition.xyz;
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
	vec4 test_pos = (INV_MODEL_MATRIX * vec4(world_pos, 1.0));

	if (abs(test_pos.x) >= (shadow_size / 2.0) || abs(test_pos.y) >= (shadow_size / 2.0) || abs(test_pos.z) >= (shadow_size / 2.0)) {
		discard;
	}

	vec2 decal_uv = (-test_pos.xz * (1.0 / shadow_size)) + 0.5;

	float vertical_offset = -test_pos.y;
	float vertical_blend = 0.0;
	if (vertical_offset >= 0.0) {
		vertical_blend = clamp(1.0 - smoothstep(0.0, shadow_height_below, vertical_offset), 0.0, 1.0);
	} else {
		vertical_blend = clamp(1.0 - smoothstep(0.0, -shadow_height_above, vertical_offset), 0.0, 1.0);
	}

	float blur = 1.0 - pow(vertical_blend, 4.0);
	float texture_levels = max(0.0, float(shadow_texture_mipmaps - 3));

	vec3 shadow = textureLod(shadow_texture, decal_uv, blur * texture_levels).rgb;

	float normal_blend = 1.0;
	#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
		vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).xyz * 2.0 - 1.0;
		vec3 world_normals = (INV_VIEW_MATRIX * vec4(normal, 0.0)).xyz;
		mat3 basis = mat3(MODEL_MATRIX);
		normal_blend = clamp(dot(basis * vec3(0.0, 1.0, 0.0), world_normals), 0.0, 1.0);
	#endif

	ALBEDO = vec3(0.0);
	ALPHA = clamp(mix(shadow_range.x, shadow_range.y, mix(0.0, 1.0 - shadow.x, vertical_blend * normal_blend * shadow_intensity)), 0.0, 1.0);
}
