// Shader updated from https://godotshaders.com/shader/lens-flare-shader/
// Originally by malhotraprateek, licensed under MIT

// TRANSLATED & MODIFIED FROM: https://www.shadertoy.com/view/4sX3Rs

shader_type spatial;
render_mode blend_add, unshaded, depth_test_disabled, depth_draw_never, fog_disabled;

uniform vec2 sun_position = vec2(0.0);
uniform bool sun_in_bounds = true;
uniform vec3 tint = vec3(1.0);
uniform float tint_multiplier = 1.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

vec3 lensflare(vec2 uv,vec2 pos)
{
	vec2 main = uv-pos;
	vec2 uvd = uv*(length(uv));

	float dist = length(main);
	dist = pow(dist,0.1);

	float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
	float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
	float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;

	vec2 uvx = mix(uv,uvd,-0.5);

	float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
	float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
	float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;

	uvx = mix(uv,uvd,-.4);

	float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
	float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
	float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;

	uvx = mix(uv,uvd,-0.5);

	float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
	float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
	float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;

	vec3 c = vec3(.0);

	c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;

	return c;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment()
{
	float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	vec2 uv = SCREEN_UV - vec2(0.5);
	uv.x *= aspect_ratio;
	vec2 sun = sun_position - vec2(0.5);
	sun.x *= aspect_ratio;

	float depth_test = 1.0;
	if (sun_in_bounds) {
		// TODO: smooth this out somehow
		depth_test = textureLod(DEPTH_TEXTURE, sun_position, 0.0).r < 0.0001 ? 1.0 : 0.0;
	}
	ALBEDO = tint * tint_multiplier * depth_test * lensflare(uv, sun.xy);
	//ALBEDO = textureLod(DEPTH_TEXTURE, sun_position, 0.0).rrr;
}