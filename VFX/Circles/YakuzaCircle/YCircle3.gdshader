shader_type spatial;

render_mode unshaded, blend_add;
uniform vec3 paleta;
uniform float MyAlpha = 1.0;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
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
float sdRipples(float d, float w, int r) {
	for (int i = 0; i < r; ++i) {
		d = abs(d)-w;
	}
	return d;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
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
uniform sampler2D texture_1;
const float texture_1_size = 1024.0;
vec2 rotate(vec2 uv, float rotate) {
 	vec2 rv;
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	return rv;
}
const float p_o179422_default_in1 = 0.000000000;
const float p_o179422_default_in2 = 0.000000000;
const float p_o179423_default_in1 = 0.000000000;
const float p_o179423_default_in2 = 2.320000000;
const float p_o179428_default_in1 = 0.000000000;
const float p_o179428_default_in2 = 0.000000000;
const float p_o179438_default_in1 = 0.000000000;
const float p_o179438_default_in2 = 0.000000000;
const float p_o179609_default_in1 = 0.000000000;
const float p_o179609_default_in2 = 0.000000000;
const float p_o179436_default_in1 = 0.000000000;
const float p_o179436_default_in2 = 0.000000000;
const float p_o179610_default_in1 = 0.000000000;
const float p_o179610_default_in2 = 0.000000000;
const float p_o179613_translate_x = 0.000000000;
const float p_o179613_translate_y = 0.000000000;
const float p_o179613_rotate = 0.000000000;
const float p_o179613_scale_x = 1.100000000;
const float p_o179613_scale_y = 1.100000000;
const float p_o179611_default_in1 = 0.000000000;
const float p_o179611_default_in2 = 1.850000000;
const float p_o179615_default_in1 = 0.060000000;
const float p_o179615_default_in2 = 1.000000000;
const float p_o179619_bevel = 0.130000000;
const float p_o179619_base = 0.870000000;
const float p_o179618_r = 0.010000000;
const float p_o179618_ripples = 1.000000000;
const float p_o179616_r = 0.400000000;
const float p_o179616_cx = 0.000000000;
const float p_o179616_cy = 0.000000000;
const float p_o275388_translate_x = 0.000000000;
const float p_o275388_translate_y = 0.000000000;
const float p_o275388_rotate = 0.000000000;
const float p_o275388_scale_x = 0.905000000;
const float p_o275388_scale_y = 0.905000000;
const float p_o179608_cx = 0.000000000;
const float p_o179608_cy = 0.000000000;
const float p_o179608_rotate = 0.000000000;
const float p_o179789_default_in1 = 0.000000000;
const float p_o179789_default_in2 = 0.000000000;
const float p_o179788_sides = 6.000000000;
const float p_o179788_radius = 1.000000000;
const float p_o179788_edge = 0.000000000;
const float p_o179787_default_in1 = 0.000000000;
const float p_o179787_default_in2 = 1.990000000;
const float p_o179784_default_in1 = 0.080000000;
const float p_o179784_default_in2 = 0.080000000;
const float p_o179698_curve_0_x = 0.000000000;
const float p_o179698_curve_0_y = 0.000000000;
const float p_o179698_curve_0_ls = 0.000000000;
const float p_o179698_curve_0_rs = 1.000000000;
const float p_o179698_curve_1_x = 1.000000000;
const float p_o179698_curve_1_y = 1.000000000;
const float p_o179698_curve_1_ls = 1.000000000;
const float p_o179698_curve_1_rs = 0.000000000;
float o179698_curve_curve_fct(float x) {
{
float dx = x - p_o179698_curve_0_x;
float d = p_o179698_curve_1_x - p_o179698_curve_0_x;
float t = dx/d;
float omt = (1.0 - t);
float omt2 = omt * omt;
float omt3 = omt2 * omt;
float t2 = t * t;
float t3 = t2 * t;
d /= 3.0;
float y1 = p_o179698_curve_0_y;
float yac = p_o179698_curve_0_y + d*p_o179698_curve_0_rs;
float ybc = p_o179698_curve_1_y - d*p_o179698_curve_1_ls;
float y2 = p_o179698_curve_1_y;
return y1*omt3 + yac*omt2*t*3.0 + ybc*omt*t2*3.0 + y2*t3;
}
}
const float p_o179421_sides = 6.000000000;
const float p_o179421_radius = 1.160000000;
const float p_o179421_edge = 0.260000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o179616_0_1_sdf2d = length((transform2_clamp(transform2((uv), vec2(p_o179613_translate_x*(2.0*1.0-1.0), p_o179613_translate_y*(2.0*1.0-1.0)), p_o179613_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o179613_scale_x*(2.0*1.0-1.0), p_o179613_scale_y*(2.0*1.0-1.0)))))-vec2(p_o179616_cx+0.5, p_o179616_cy+0.5))-p_o179616_r;
float o179618_0_1_sdf2d = sdRipples(o179616_0_1_sdf2d, p_o179618_r, int(p_o179618_ripples));
float o179619_0_1_f = clamp(p_o179619_base-o179618_0_1_sdf2d/max(p_o179619_bevel, 0.00001), 0.0, 1.0);
vec4 o179614_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o179619_0_1_f), 1.0).rgb, vec4(vec3(o179619_0_1_f), 1.0).a);
float o179615_0_clamp_false = p_o179615_default_in1/(dot((o179614_0_1_rgba).rgb, vec3(1.0))/3.0);
float o179615_0_clamp_true = clamp(o179615_0_clamp_false, 0.0, 1.0);
float o179615_0_2_f = o179615_0_clamp_false;
float o179611_0_clamp_false = pow(o179615_0_2_f,p_o179611_default_in2);
float o179611_0_clamp_true = clamp(o179611_0_clamp_false, 0.0, 1.0);
float o179611_0_2_f = o179611_0_clamp_false;
vec4 o179613_0_1_rgba = vec4(vec3(o179611_0_2_f), 1.0);
float o179616_0_3_sdf2d = length((transform2_clamp(transform2((uv), vec2(p_o275388_translate_x*(2.0*1.0-1.0), p_o275388_translate_y*(2.0*1.0-1.0)), p_o275388_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o275388_scale_x*(2.0*1.0-1.0), p_o275388_scale_y*(2.0*1.0-1.0)))))-vec2(p_o179616_cx+0.5, p_o179616_cy+0.5))-p_o179616_r;
float o179618_0_3_sdf2d = sdRipples(o179616_0_3_sdf2d, p_o179618_r, int(p_o179618_ripples));
float o179619_0_3_f = clamp(p_o179619_base-o179618_0_3_sdf2d/max(p_o179619_bevel, 0.00001), 0.0, 1.0);
vec4 o179614_0_3_rgba = vec4(vec3(1.0)-vec4(vec3(o179619_0_3_f), 1.0).rgb, vec4(vec3(o179619_0_3_f), 1.0).a);
float o179615_3_clamp_false = p_o179615_default_in1/(dot((o179614_0_3_rgba).rgb, vec3(1.0))/3.0);
float o179615_3_clamp_true = clamp(o179615_3_clamp_false, 0.0, 1.0);
float o179615_0_5_f = o179615_3_clamp_false;
float o179611_3_clamp_false = pow(o179615_0_5_f,p_o179611_default_in2);
float o179611_3_clamp_true = clamp(o179611_3_clamp_false, 0.0, 1.0);
float o179611_0_5_f = o179611_3_clamp_false;
vec4 o275388_0_1_rgba = vec4(vec3(o179611_0_5_f), 1.0);
float o179610_0_clamp_false = (dot((o179613_0_1_rgba).rgb, vec3(1.0))/3.0)+(dot((o275388_0_1_rgba).rgb, vec3(1.0))/3.0);
float o179610_0_clamp_true = clamp(o179610_0_clamp_false, 0.0, 1.0);
float o179610_0_1_f = o179610_0_clamp_false;
float o179436_0_clamp_false = p_o179436_default_in1+o179610_0_1_f;
float o179436_0_clamp_true = clamp(o179436_0_clamp_false, 0.0, 1.0);
float o179436_0_2_f = o179436_0_clamp_false;
vec2 o179608_0_c = vec2(0.5+p_o179608_cx, 0.5+p_o179608_cy);float o179788_0_1_f = shape_circle((rotate((uv)-o179608_0_c, p_o179608_rotate*0.01745329251)+o179608_0_c), p_o179788_sides, p_o179788_radius*1.0, p_o179788_edge*1.0);
vec4 o179642_0 = textureLod(texture_1, (rotate((uv)-o179608_0_c, p_o179608_rotate*0.01745329251)+o179608_0_c), 0.0);
float o179723_0_1_f = 1.0 - (dot((o179642_0).rgb, vec3(1.0))/3.0);
float o179698_0_1_f = o179698_curve_curve_fct(o179723_0_1_f);
float o179784_0_clamp_false = p_o179784_default_in1/o179698_0_1_f;
float o179784_0_clamp_true = clamp(o179784_0_clamp_false, 0.0, 1.0);
float o179784_0_2_f = o179784_0_clamp_false;
float o179787_0_clamp_false = pow(o179784_0_2_f,p_o179787_default_in2);
float o179787_0_clamp_true = clamp(o179787_0_clamp_false, 0.0, 1.0);
float o179787_0_2_f = o179787_0_clamp_false;
float o179789_0_clamp_false = o179788_0_1_f*o179787_0_2_f;
float o179789_0_clamp_true = clamp(o179789_0_clamp_false, 0.0, 1.0);
float o179789_0_1_f = o179789_0_clamp_false;
vec4 o179608_0_1_rgba = vec4(vec3(o179789_0_1_f), 1.0);
float o179609_0_clamp_false = o179436_0_2_f+(dot((o179608_0_1_rgba).rgb, vec3(1.0))/3.0);
float o179609_0_clamp_true = clamp(o179609_0_clamp_false, 0.0, 1.0);
float o179609_0_1_f = o179609_0_clamp_false;
float o179438_0_clamp_false = o179609_0_1_f+p_o179438_default_in2;
float o179438_0_clamp_true = clamp(o179438_0_clamp_false, 0.0, 1.0);
float o179438_0_2_f = o179438_0_clamp_false;
float o179428_0_clamp_false = o179438_0_2_f+p_o179428_default_in2;
float o179428_0_clamp_true = clamp(o179428_0_clamp_false, 0.0, 1.0);
float o179428_0_2_f = o179428_0_clamp_false;
float o179423_0_clamp_false = pow(o179428_0_2_f,p_o179423_default_in2);
float o179423_0_clamp_true = clamp(o179423_0_clamp_false, 0.0, 1.0);
float o179423_0_2_f = o179423_0_clamp_true;
float o179421_0_1_f = shape_circle((uv), p_o179421_sides, p_o179421_radius*1.0, p_o179421_edge*1.0);
float o179422_0_clamp_false = o179423_0_2_f*o179421_0_1_f;
float o179422_0_clamp_true = clamp(o179422_0_clamp_false, 0.0, 1.0);
float o179422_0_1_f = o179422_0_clamp_false;

	vec4 color_tex = vec4(vec3(o179422_0_1_f), 1.0);
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb*paleta*MyAlpha;
	ALPHA = color_tex.a*MyAlpha;

}
