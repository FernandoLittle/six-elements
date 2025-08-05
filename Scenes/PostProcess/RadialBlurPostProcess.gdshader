shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;


uniform int Iterations=1;
uniform float blurParameter=0.001;
uniform float centerx=0.5;
uniform float centery=0.5;

void fragment() {
	vec2 center=vec2(centerx,centery);
	vec2 uv = SCREEN_UV;
	vec2 dist = center-uv;
	//dist=1.0-dist;
	vec4 color= texture(SCREEN_TEXTURE,uv);
	for(int x = 0; x<Iterations;x++)
	{
		uv+=blurParameter*dist;
		color+=texture(SCREEN_TEXTURE,uv);
		//color/=2.0;
	}
	color/=float(Iterations+1);

	COLOR=vec4(color);

}


