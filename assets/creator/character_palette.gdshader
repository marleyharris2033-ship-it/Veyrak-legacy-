shader_type canvas_item;
uniform vec4 skin_tone : source_color = vec4(0.659, 0.612, 0.565, 1.0);
uniform vec4 hair_tone : source_color = vec4(0.137, 0.149, 0.196, 1.0);
uniform vec4 eye_tone : source_color = vec4(0.6, 0.86, 0.94, 1.0);
uniform bool change_skin = false;
uniform bool change_hair = false;
uniform bool change_eyes = false;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float top = max(c.r, max(c.g, c.b));
	float low = min(c.r, min(c.g, c.b));
	float sat = (top - low) / max(top, 0.001);
	// Restrict the skin palette to warm, desaturated flesh above the belt
	// and the hands. Saturated gold and cool blue markings stay unchanged.
	bool flesh_area = UV.y < 0.375 || (UV.y > 0.47 && UV.y < 0.54);
	bool flesh = flesh_area && c.r > c.g * 1.035 && c.g > c.b * 1.06 && sat < 0.47 && c.r > 0.17;
	if (change_skin && flesh) {
		float value = dot(c.rgb, vec3(0.30, 0.59, 0.11));
		c.rgb = clamp(skin_tone.rgb * value / 0.62, vec3(0.0), vec3(1.0));
	}
	bool hair_area = UV.y < 0.086 || (UV.x < 0.496 && UV.y < 0.175);
	bool ear_area = UV.x > 0.46 && UV.x < 0.535 && UV.y > 0.10;
	if (change_hair && hair_area && !ear_area && !flesh && sat < 0.42 && top > 0.03) {
		float value = dot(c.rgb, vec3(0.30, 0.59, 0.11));
		c.rgb = clamp(hair_tone.rgb * (0.38 + value * 1.5), vec3(0.0), vec3(1.0));
	}
	bool eye_area = UV.x > 0.547 && UV.x < 0.576 && UV.y > 0.115 && UV.y < 0.128;
	if (change_eyes && eye_area && c.b > 0.5 && sat < 0.35) c.rgb = eye_tone.rgb * max(top, 0.6);
	COLOR = c;
}
