shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

uniform float StepPower:hint_range(0.0, 1.0, 0.01);

uniform float Invert:hint_range(0.0, 1.0, 0.01);





void fragment() {

	vec2 uv = SCREEN_UV;

	vec4 color= texture(SCREEN_TEXTURE,uv);

	color.r=step(color.r,StepPower);
	float color1=1.0-color.r;
	float finalcolor= mix(color1,color.r,Invert);
	COLOR=vec4(finalcolor,finalcolor,finalcolor,1.0);

}


