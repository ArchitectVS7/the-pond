shader_type canvas_item;

// Tunable parameters
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.2;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.8;
uniform vec4 background_color : source_color = vec4(0.545, 0.353, 0.235, 1.0);

void fragment() {
	// Get UV coordinates centered at 0.5, 0.5
	vec2 uv = UV - vec2(0.5);

	// Calculate distance from center
	float dist = length(uv);

	// Create vignette effect with smooth falloff
	float vignette = smoothstep(vignette_radius, vignette_radius - 0.3, dist);
	vignette = mix(1.0 - vignette_strength, 1.0, vignette);

	// Apply vignette to background color
	vec3 final_color = background_color.rgb * vignette;

	// Output with full alpha
	COLOR = vec4(final_color, background_color.a);
}
