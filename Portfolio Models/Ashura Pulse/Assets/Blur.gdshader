shader_type spatial;
render_mode unshaded;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable,filter_nearest;
uniform float blur_power;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 color=texture(screen_texture,SCREEN_UV).rgb;
	vec2 uv_blur= vec2(SCREEN_UV.x+blur_power,SCREEN_UV.y);
	vec3 color1=texture(screen_texture,uv_blur).rgb;
	vec3 color_final=vec3(0.0,0.0,0.0);
	color_final.r=(color.r+color1.r)/2.0;
	color_final.g=(color.g+color1.g)/2.0;
	color_final.b=(color.b+color1.b)/2.0;
	ALBEDO=color_final;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
