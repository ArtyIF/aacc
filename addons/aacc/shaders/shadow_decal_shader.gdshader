// Based on the shader at https://godotshaders.com/shader/decal-example/
// written by TwistedTwigleg and published under the MIT license

shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_front, depth_test_disabled, blend_mul, fog_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D shadow_texture : source_color, hint_default_black, repeat_disable;
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
	if (CURRENT_RENDERER == RENDERER_COMPATIBILITY) {
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
	shadow = mix(shadow, vec3(grayscale(shadow)), shadow_grayscale);

	shadow = vec3(1.0) - shadow;
	shadow *= vec3(1.0) - (shadow_color * shadow_color_amount);
	shadow = clamp(vec3(1.0) - shadow, 0.0, 1.0);

	ALBEDO = mix(vec3(1.0), shadow, vertical_blend);
	if (CURRENT_RENDERER == RENDERER_COMPATIBILITY || CURRENT_RENDERER == RENDERER_MOBILE) {
		// Compatibility and Mobile renderers seem to use some tricks for HDR
		// that break multiplication blend modes right now.
		//
		// Not sure where the value below comes from (got it from trial and
		// error, and may not even be right on other GPUs/platforms), but this
		// is where the shadow cube completely stops darkening the image (at
		// least on my PC).
		//
		// NOTE: This value is unnecessary when glow is disabled and tonemap's
		// white value is 1. It might require adjusting with other white values.
		ALBEDO *= 3.719675661;
	}
}
