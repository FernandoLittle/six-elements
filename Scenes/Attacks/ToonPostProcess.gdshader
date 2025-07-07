shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform float cut: hint_range(0.0, 1.0, 0.01)=0.9;
uniform vec3 line_color: source_color = vec3(0.043, 0.282, 0.467);
uniform vec3 background_color: source_color = vec3(0.408, 0.969, 0.694);
uniform float offseto=0.5;
uniform float pixelz=0.001;
uniform float rotation1=1.0;
uniform float rotation2=1.0;

uniform float fraction=100.;
uniform float colorfull=2.0;
uniform float power=1.0;
uniform float shadowpower=0.0;
uniform float shadowpower2=0.0;
float get_pixel(sampler2D tex, vec2 uv, vec2 offset)
{
	return step(cut,1.0 -distance(texture(tex,uv),texture(tex,uv+offset)));

}

void vertex() {
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	POSITION = vec4(VERTEX.xy, rotation1, rotation2);
	// Called for every vertex the material is visible on.
}

void fragment() {

		//vec2 ps = TEXTURE_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;
	//float pixel =get_pixel(TEXTURE,uv,vec2(ps.x,0.0));
	vec4 color= texture(SCREEN_TEXTURE,uv);
	color=color*colorfull;

	float pixel =get_pixel(SCREEN_TEXTURE,uv,vec2(pixelz,pixelz));
	float pixel2 =get_pixel(SCREEN_TEXTURE,uv,vec2(-pixelz,-pixelz));
	float pixel3=pixel2*pixel;
	color= color*pixel3;
	
	//.....

	color.r=pow(color.r,power);
	color.g=pow(color.g,power);
	color.b=pow(color.b,power);
	
	
	
	float mixcolor=(color.r+color.g+color.b)/3.0;
	color.r=color.r*smoothstep(shadowpower,shadowpower2,mixcolor);
	color.g=color.g*smoothstep(shadowpower,shadowpower2,mixcolor);
	color.b=color.b*smoothstep(shadowpower,shadowpower2,mixcolor);
	
	//ALBEDO=vec3(pixel3);
	ALBEDO=color.rgb;
	//ALBEDO=testcolor;
	// Called for every pixel the material is visible on.
}
void SolidColors(){
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}