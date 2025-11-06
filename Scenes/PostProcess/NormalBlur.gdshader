shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;


uniform int Iterations=1;
uniform float blurParameter=0.001;



void fragment() {

	vec2 uv = SCREEN_UV;

	vec4 color= texture(SCREEN_TEXTURE,uv);
	for(int x = 0; x<Iterations;x++)
	{
		uv+=blurParameter;
		color+=texture(SCREEN_TEXTURE,uv);
		color/=2.0;
	}


	COLOR=vec4(color);

}
