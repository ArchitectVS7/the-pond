shader_type canvas_item;

// Colorblind filter modes
// 0 = Normal (no filter)
// 1 = Deuteranopia (red-green, most common)
// 2 = Protanopia (red-blind)
// 3 = Tritanopia (blue-yellow)
uniform int filter_mode : hint_range(0, 3) = 0;
uniform float filter_strength : hint_range(0.0, 1.0) = 1.0;

// Colorblind transformation matrices based on research by Hans Brettel et al.
// and Vienot, Brettel, and Mollon (1999)

vec3 apply_deuteranopia(vec3 color) {
    // Deuteranopia (red-green colorblindness, affects green cones)
    mat3 transform = mat3(
        vec3(0.625, 0.375, 0.0),
        vec3(0.7, 0.3, 0.0),
        vec3(0.0, 0.3, 0.7)
    );
    return transform * color;
}

vec3 apply_protanopia(vec3 color) {
    // Protanopia (red-blindness, affects red cones)
    mat3 transform = mat3(
        vec3(0.567, 0.433, 0.0),
        vec3(0.558, 0.442, 0.0),
        vec3(0.0, 0.242, 0.758)
    );
    return transform * color;
}

vec3 apply_tritanopia(vec3 color) {
    // Tritanopia (blue-yellow colorblindness, affects blue cones)
    mat3 transform = mat3(
        vec3(0.95, 0.05, 0.0),
        vec3(0.0, 0.433, 0.567),
        vec3(0.0, 0.475, 0.525)
    );
    return transform * color;
}

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    vec3 rgb = original_color.rgb;

    // Apply selected colorblind filter
    vec3 filtered_color = rgb;

    if (filter_mode == 1) {
        filtered_color = apply_deuteranopia(rgb);
    } else if (filter_mode == 2) {
        filtered_color = apply_protanopia(rgb);
    } else if (filter_mode == 3) {
        filtered_color = apply_tritanopia(rgb);
    }

    // Blend between original and filtered based on strength
    vec3 final_color = mix(rgb, filtered_color, filter_strength);

    COLOR = vec4(final_color, original_color.a);
}
