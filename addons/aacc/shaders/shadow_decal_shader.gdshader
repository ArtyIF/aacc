// Based on the shader at https://godotshaders.com/shader/decal-example/
// written by TwistedTwigleg and published under the MIT license

shader_type spatial;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
render_mode world_vertex_coords, unshaded, cull_front, depth_test_disabled, blend_mix, fog_disabled;
#else
render_mode world_vertex_coords, unshaded, cull_front, depth_test_disabled, blend_mul, fog_disabled;
#endif

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear;
#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
	uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;
#endif

uniform sampler2D shadow_texture : source_color, hint_default_black, repeat_disable, filter_linear_mipmap_anisotropic;
uniform int shadow_texture_mipmaps = 9;

uniform float shadow_size = 4.0;
uniform float shadow_height_above = 0.25;
uniform float shadow_height_below = 1.25;
uniform float shadow_grayscale : hint_range(0.0, 1.0) = 0.0;
uniform vec3 shadow_color : source_color = vec3(0.0);
uniform float shadow_color_amount : hint_range(0.0, 1.0) = 0.5;
uniform vec2 shadow_ramp = vec2(0.1, 1.0);

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

float inverse_lerp(float a, float b, float x) {
	return (x - a) / (b - a);
}

vec3 multi_channel_inverse_lerp(vec3 a, vec3 b, vec3 x) {
	vec3 result = vec3(0.0);
	result.r = inverse_lerp(a.r, b.r, x.r);
	result.g = inverse_lerp(a.g, b.g, x.g);
	result.b = inverse_lerp(a.b, b.b, x.b);
	return result;
}

float grayscale(vec3 input) {
	return dot(input, vec3(0.2126, 0.7152, 0.0722));
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
	shadow = multi_channel_inverse_lerp(vec3(shadow_ramp.x), vec3(shadow_ramp.y), clamp(shadow, vec3(0.0), vec3(1.0)));

	#if CURRENT_RENDERER != RENDERER_COMPATIBILITY
		shadow = mix(shadow, vec3(grayscale(shadow)), shadow_grayscale);

		shadow = vec3(1.0) - shadow;
		shadow *= vec3(1.0) - (shadow_color * shadow_color_amount);
		shadow = clamp(vec3(1.0) - shadow, 0.0, 1.0);

		float normal_blend = 1.0;
		#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
			vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).xyz * 2.0 - 1.0;
			vec3 world_normals = (INV_VIEW_MATRIX * vec4(normal, 0.0)).xyz;
			mat3 basis = mat3(MODEL_MATRIX);
			normal_blend = clamp(dot(basis * vec3(0.0, 1.0, 0.0), world_normals), 0.0, 1.0);
		#endif

		ALBEDO = mix(vec3(1.0), shadow, vertical_blend * normal_blend);

		#if CURRENT_RENDERER == RENDERER_MOBILE
			// Keep in mind that the rendering breaks for some reason when MSAA is
			// enabled. Try using FXAA instead.
			ALBEDO *= 2.0;
		#endif
	#else
		shadow = vec3(grayscale(shadow));
		ALBEDO = vec3(shadow_color * shadow_color_amount);
		ALPHA = mix(0.0, 1.0 - shadow.x, vertical_blend);
	#endif
}
