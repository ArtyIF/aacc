// Based on the shader at https://godotshaders.com/shader/decal-example/
// written by TwistedTwigleg and published under the MIT license

// For some reason, it doesn't work on Mobile renderer, at least when testing
// on my PC. I haven't tested on phones yet

shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_front, depth_test_disabled, blend_mul;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D shadow_texture : source_color, hint_default_black;
uniform int shadow_texture_mipmaps = 9;

uniform float shadow_size = 4.0;
uniform float shadow_height_above = 0.25;
uniform float shadow_height_below = 1.25;
uniform vec3 shadow_color : source_color = vec3(0.0);
uniform float shadow_lightness: hint_range(0.0, 1.0) = 0.5;
uniform vec2 shadow_ramp = vec2(0.0, 1.0);

varying mat4 INV_MODEL_MATRIX;

void vertex() {
	INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
}

// Credit: https://stackoverflow.com/questions/32227283/getting-world-position-from-depth-buffer-value
vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view, bool compatibility) {
	float z = depth;
	if (compatibility) {
		z *= 2.0;
		z -= 1.0;
	}
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	return worldSpacePosition.xyz;
}

float inverse_lerp(float a, float b, float x) {
	return (x - a) / (b - a);
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, OUTPUT_IS_SRGB);
	vec4 test_pos = (INV_MODEL_MATRIX * vec4(world_pos, 1.0));

	if (abs(test_pos.x) >= (shadow_size / 2.0) || abs(test_pos.y) >= (shadow_size / 2.0) || abs(test_pos.z) >= (shadow_size / 2.0)) {
		discard;
	}

	vec2 decal_uv = (-test_pos.xz * (1.0 / shadow_size)) + 0.5;

	float vertical_offset = -test_pos.y;
	float vertical_blend = 0.0;
	// TODO: export
	if (vertical_offset >= 0.0) {
		vertical_blend = clamp(1.0 - smoothstep(0.0, shadow_height_below, vertical_offset), 0.0, 1.0);
	} else {
		vertical_blend = clamp(1.0 - smoothstep(0.0, -shadow_height_above, vertical_offset), 0.0, 1.0);
	}

	float blur = 1.0 - pow(vertical_blend, 4.0);
	float texture_levels = max(0.0, float(shadow_texture_mipmaps - 3));
	float shadow = textureLod(shadow_texture, decal_uv, blur * texture_levels).r;

	float result = inverse_lerp(shadow_ramp.x, shadow_ramp.y, clamp((1.0 - shadow) * vertical_blend, 0.0, 1.0));
	ALBEDO = mix(vec3(1.0), shadow_color * shadow_lightness, result);
	if (OUTPUT_IS_SRGB) { // Compatibility
		// Compatibility renderer doesn't use HDR, so I guess it uses some tricks
		// for multiplication to allow for a higher dynamic range
		//
		// Not sure where the value below comes from (got it from trial and
		// error, and may not even be right on other GPUs/platforms), but this
		// is where the shadow cube completely stops darkening the image (at
		// least on my PC).
		ALBEDO *= 3.719675661;
	}
}
