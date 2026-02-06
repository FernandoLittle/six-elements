shader_type spatial;

render_mode unshaded, blend_add;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
uniform vec3 custom_color = vec3(1.0, 1.0, 1.0);
uniform float my_alpha= 1.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
uniform sampler2D texture_1;
const float texture_1_size = 64.0;
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
const float p_o577592_default_in1 = 0.000000000;
const float p_o577592_default_in2 = 0.000000000;
const float p_o528402_default_in1 = 0.000000000;
const float p_o528402_default_in2 = 0.000000000;
const float p_o424151_translate_x = 0.000000000;
const float p_o424151_translate_y = 0.000000000;
const float p_o424151_rotate = 18.565000000;
const float p_o424151_scale_x = -1.000000000;
const float p_o424151_scale_y = 1.000000000;
const float p_o424155_radius = 5.100000000;
const float p_o424155_repeat = 1.000000000;
const float p_o424145_translate_x = 0.000000000;
const float p_o424145_translate_y = 0.000000000;
const float p_o424145_rotate = 0.000000000;
const float p_o424145_scale_x = 1.000000000;
const float p_o424145_scale_y = 1.000000000;
const float p_o424144_default_in1 = 0.611200000;
const float p_o424144_default_in2 = 0.000000000;
const float p_o424131_repeat = 1.000000000;
const float p_o424131_rotate = 90.000000000;
const float p_o424131_gradient_0_pos = 0.000000000;
const vec4 p_o424131_gradient_0_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o424131_gradient_1_pos = 1.000000000;
const vec4 p_o424131_gradient_1_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
vec4 o424131_gradient_gradient_fct(float x) {
  if (x < p_o424131_gradient_0_pos) {
    return p_o424131_gradient_0_col;
  } else if (x < p_o424131_gradient_1_pos) {
    return mix(p_o424131_gradient_0_col, p_o424131_gradient_1_col, ((x-p_o424131_gradient_0_pos)/(p_o424131_gradient_1_pos-p_o424131_gradient_0_pos)));
  }
  return p_o424131_gradient_1_col;
}
const float p_o424153_translate_x = 0.000000000;
const float p_o520928_sides = 6.000000000;
const float p_o520928_radius = 0.850000000;
const float p_o520928_edge = 0.410000000;
const float p_o569321_sides = 6.000000000;
const float p_o569321_radius = 0.550000000;
const float p_o569321_edge = 0.820000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o424156_0_1_f = (log2(distance((uv),vec2(.5)))/log2(.7091));
float o424131_0_r = 0.5+(cos(p_o424131_rotate*0.01745329251)*((vec2(fract(p_o424155_repeat*atan((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o424155_radius*length((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))).x-0.5)+sin(p_o424131_rotate*0.01745329251)*((vec2(fract(p_o424155_repeat*atan((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o424155_radius*length((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))).y-0.5))/(cos(abs(mod(p_o424131_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o424131_0_1_rgba = o424131_gradient_gradient_fct(fract(o424131_0_r*p_o424131_repeat));
float o424144_0_clamp_false = p_o424144_default_in1/(dot((o424131_0_1_rgba).rgb, vec3(1.0))/3.0);
float o424144_0_clamp_true = clamp(o424144_0_clamp_false, 0.0, 1.0);
float o424144_0_2_f = o424144_0_clamp_false;
vec4 o424146_0 = textureLod(texture_1, ((fract(transform2((vec2(fract(p_o424155_repeat*atan((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o424155_radius*length((transform2((uv), vec2(p_o424151_translate_x*(2.0*1.0-1.0), p_o424151_translate_y*(2.0*1.0-1.0)), p_o424151_rotate*0.01745329251*(2.0*o424156_0_1_f-1.0), vec2(p_o424151_scale_x*(2.0*1.0-1.0), p_o424151_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))), vec2(p_o424145_translate_x*(2.0*1.0-1.0), p_o424145_translate_y*(2.0*1.0-1.0)), p_o424145_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o424145_scale_x*(2.0*1.0-1.0), p_o424145_scale_y*(2.0*o424144_0_2_f-1.0)))))-vec2(p_o424153_translate_x, (elapsed_time*-1.0))), 0.0);
float o424152_1_1_f = o424146_0.g;
vec4 o424153_0_1_rgba = vec4(vec3(o424152_1_1_f), 1.0);
vec4 o424145_0_1_rgba = o424153_0_1_rgba;
vec4 o424155_0_1_rgba = o424145_0_1_rgba;
vec4 o424151_0_1_rgba = o424155_0_1_rgba;
vec4 o493740_0_1_rgba = vec4(vec3(1.0)-o424151_0_1_rgba.rgb, o424151_0_1_rgba.a);
float o520928_0_1_f = shape_circle((uv), p_o520928_sides, p_o520928_radius*1.0, p_o520928_edge*1.0);
float o528402_0_clamp_false = (dot((o493740_0_1_rgba).rgb, vec3(1.0))/3.0)*o520928_0_1_f;
float o528402_0_clamp_true = clamp(o528402_0_clamp_false, 0.0, 1.0);
float o528402_0_1_f = o528402_0_clamp_false;
float o569321_0_1_f = shape_circle((uv), p_o569321_sides, p_o569321_radius*1.0, p_o569321_edge*1.0);
vec4 o583102_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o569321_0_1_f), 1.0).rgb, vec4(vec3(o569321_0_1_f), 1.0).a);
float o577592_0_clamp_false = o528402_0_1_f*(dot((o583102_0_1_rgba).rgb, vec3(1.0))/3.0);
float o577592_0_clamp_true = clamp(o577592_0_clamp_false, 0.0, 1.0);
float o577592_0_1_f = o577592_0_clamp_false;

	vec4 color_tex = vec4(vec3(o577592_0_1_f), 1.0);
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb*custom_color;
	ALPHA = color_tex.a*my_alpha;

}



