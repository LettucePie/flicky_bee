shader_type spatial;

uniform sampler2D noise:source_color,repeat_enable;
uniform vec4 gradientRemap = vec4(0.708, -2.683, 0, 0.264);
uniform vec4 beamRemap = vec4(0.404, 1.12, 1, 200.0);
uniform vec4 color1:source_color;
uniform vec4 color2:source_color;
uniform vec3 scale = vec3(1.0, 50.0, 0);
uniform float threshold = 0.993;
uniform float offset = 1.5;


vec3 blend_linear_light(vec3 base, vec3 blend, float opacity) {
	blend.r = base.r > 0.5 ? blend.r + opacity * ((2.0 * base.r) - 0.5) : blend.r + opacity * ((2.0 * base.r) - 1.0);
	blend.g = base.g > 0.5 ? blend.g + opacity * ((2.0 * base.g) - 0.5) : blend.g + opacity * ((2.0 * base.g) - 1.0);
	blend.b = base.b > 0.5 ? blend.b + opacity * ((2.0 * base.b) - 0.5) : blend.b + opacity * ((2.0 * base.b) - 1.0);
	return blend;
}
float map(float value, float from_min, float from_max, float to_min, float to_max) {
	return abs(from_max - from_min) > 0.0001 ? 
		to_min + (from_min > from_max ? 1.0 - smoothstep(from_max, from_min, value) : smoothstep(from_min, from_max, value)) * (to_max - to_min) : 
		0.0;
}

void fragment() {
	vec2 uv = vec2((UV.x*2.0)-1.0, (UV.y*2.0)-1.0);
	vec3 n = texture(noise, uv+vec2(TIME*offset, 0)).rgb;
	float remap = map(uv.x, gradientRemap.x, gradientRemap.y, gradientRemap.z, gradientRemap.w);
	vec3 col = (blend_linear_light(n, vec3(uv.xy, 1), remap));
	vec3 scaled_col = col * scale;
	float len = length(scaled_col);
	float clamped = len < threshold ? 1.0 : 0.0;
	vec3 color = mix(color1, color2, clamped).rgb;
	float scale_factor = map(uv.x, beamRemap.x, beamRemap.y, beamRemap.z, beamRemap.w);
	EMISSION = color * scale_factor;
	ALBEDO = color;
}