shader_type spatial;

//render_mode unshaded, blend_add;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 paleta = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
uniform float step1 = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
		mat4 n_out2p0;
// GetBillboardMatrix:2
	{
		mat4 __wm = mat4(normalize(INV_VIEW_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]), normalize(INV_VIEW_MATRIX[2]), MODEL_MATRIX[3]);
		__wm = __wm * mat4(vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		__wm = __wm * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		n_out2p0 = VIEW_MATRIX * __wm;
	}


// Output:0
	MODELVIEW_MATRIX = n_out2p0;
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
vec2 rotate(vec2 uv, float rotate) {
 	vec2 rv;
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	return rv;	
}
vec2 swirl_tile_false(vec2 uv, vec2 center, float radius, float angle) {
	vec2 v = uv-center;
	float l = length(v);
	if (l > radius) {
		return uv;
	} else {
		return rotate(v, angle*(1.0-l/radius)*(1.0-l/radius))+center;
	}
}
vec2 swirl_tile_true(vec2 uv, vec2 center, float radius, float angle) {
	center = fract(center);
	vec2 tile_offset = 2.0*(step(vec2(0.5), uv)-vec2(0.5));
	uv = swirl_tile_false(uv, center, radius, angle);
	uv = swirl_tile_false(uv, center+tile_offset, radius, angle);
	uv = swirl_tile_false(uv, center+vec2(tile_offset.x, 0.0), radius, angle);
	return swirl_tile_false(uv, center+vec2(0.0, tile_offset.y), radius, angle);
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
uniform sampler2D texture_2;
const float texture_2_size = 512.0;
uniform sampler2D texture_3;
const float texture_3_size = 256.0;
uniform sampler2D texture_4;
const float texture_4_size = 128.0;
const float p_o30695_translate_x = 0.000000000;
const float p_o30695_translate_y = 0.000000000;
const float p_o30695_rotate = 0.000000000;
const float p_o30695_scale_x = 0.600000000;
const float p_o30695_scale_y = 0.600000000;
const float p_o29625_d_in1_x = 0.000000000;
const float p_o29625_d_in1_y = 0.000000000;
const float p_o29625_d_in1_z = 0.000000000;
const float p_o29625_d_in2_x = 4.550000000;
const float p_o29625_d_in2_y = 4.700000000;
const float p_o29625_d_in2_z = 6.290000000;
const float p_o29619_d_in1_x = 0.000000000;
const float p_o29619_d_in1_y = 0.000000000;
const float p_o29619_d_in1_z = 0.000000000;
const float p_o29619_d_in2_x = 1.060000000;
const float p_o29619_d_in2_y = 0.720000000;
const float p_o29619_d_in2_z = 0.660000000;
const float p_o29593_d_in1_x = 0.000000000;
const float p_o29593_d_in1_y = 0.000000000;
const float p_o29593_d_in1_z = 0.000000000;
const float p_o29593_d_in2_x = 1.730000000;
const float p_o29593_d_in2_y = 1.050000000;
const float p_o29593_d_in2_z = 1.040000000;
const float p_o29628_amount1 = 2.000000000;
const float p_o29628_amount2 = 1.140000000;
const float p_o29628_amount3 = 1.500000000;
const float p_o29628_amount4 = 8.000000000;
const float p_o30698_amount1 = 1.000000000;
const float p_o30698_amount2 = 1.000000000;
const float p_o29618_value = 0.410000000;
const float p_o29618_width = 0.400000000;
const float p_o29617_default_in1 = 0.000000000;
const float p_o29617_default_in2 = 0.000000000;
const float p_o29616_default_in1 = 0.000000000;
const float p_o29616_default_in2 = 0.000000000;
const float p_o29615_sides = 6.000000000;
const float p_o29615_radius = 2.530000000;
const float p_o29615_edge = 0.930000000;
const float p_o29624_cx = 0.000000000;
const float p_o29624_cy = 0.000000000;
const float p_o29599_cx = 0.000000000;
const float p_o29599_cy = 0.000000000;
const float p_o29599_angle = 170.000000000;
const float p_o29599_radius = 2.050000000;
const float p_o29600_radius = 2.900000000;
const float p_o29600_repeat = 1.000000000;
const float p_o29621_translate_x = 0.000000000;
const float p_o29621_translate_y = 0.000000000;
const float p_o29621_rotate = 0.000000000;
const float p_o29621_scale_x = 1.000000000;
const float p_o29621_scale_y = 1.000000000;
const float p_o29620_default_in1 = 1.000000000;
const float p_o29620_default_in2 = 0.000000000;
const float p_o29641_repeat = 1.000000000;
const float p_o29641_rotate = 90.000000000;
const float p_o29641_gradient_0_pos = 0.000000000;
const vec4 p_o29641_gradient_0_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o29641_gradient_1_pos = 1.000000000;
const vec4 p_o29641_gradient_1_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
vec4 o29641_gradient_gradient_fct(float x) {
  if (x < p_o29641_gradient_0_pos) {
    return p_o29641_gradient_0_col;
  } else if (x < p_o29641_gradient_1_pos) {
    return mix(p_o29641_gradient_0_col, p_o29641_gradient_1_col, ((x-p_o29641_gradient_0_pos)/(p_o29641_gradient_1_pos-p_o29641_gradient_0_pos)));
  }
  return p_o29641_gradient_1_col;
}
const float p_o29654_translate_x = 0.000000000;
const float p_o29614_default_in1 = 0.000000000;
const float p_o29614_default_in2 = 0.000000000;
const float p_o29601_repeat = 1.000000000;
const float p_o29601_gradient_0_pos = 0.000000000;
const vec4 p_o29601_gradient_0_col = vec4(0.058594000, 0.058594000, 0.058594000, 1.000000000);
const float p_o29601_gradient_1_pos = 0.416212000;
const vec4 p_o29601_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o29601_gradient_gradient_fct(float x) {
  if (x < p_o29601_gradient_0_pos) {
    return p_o29601_gradient_0_col;
  } else if (x < p_o29601_gradient_1_pos) {
    return mix(p_o29601_gradient_0_col, p_o29601_gradient_1_col, (x-p_o29601_gradient_0_pos)/(p_o29601_gradient_1_pos-p_o29601_gradient_0_pos));
  }
  return p_o29601_gradient_1_col;
}
const float seed_o29594 = 0.739189982;
const float p_o29594_count = 32.000000000;
const float p_o29656_amount1 = 1.000000000;
const float p_o29592_translate_x = 0.240000000;
const float p_o29592_translate_y = 0.240000000;
const float p_o29592_rotate = 0.000000000;
const float p_o29592_scale_x = 0.500000000;
const float p_o29592_scale_y = 0.500000000;
const float p_o30709_amount1 = 1.000000000;
const float p_o30709_amount2 = 1.000000000;
const float p_o30703_in_min = 0.250000000;
const float p_o30703_in_max = 1.000000000;
const float p_o30703_out_min = 0.000000000;
const float p_o30703_out_max = 0.100000000;
const float p_o30707_default_in1 = 0.000000000;
const float p_o30707_default_in2 = 0.000000000;
const float seed_o30708 = 0.295001425;
const float seed_o30705 = 0.391376600;
const float seed_o30704 = 0.717496037;
const float p_o30713_in_min = -1.000000000;
const float p_o30713_in_max = 1.000000000;
const float p_o30713_out_min = 0.000000000;
const float p_o30713_out_max = 1.000000000;
const float p_o30712_amount1 = 1.000000000;
const float p_o30711_d_in1_x = 0.000000000;
const float p_o30711_d_in1_y = 0.000000000;
const float p_o30711_d_in1_z = 0.000000000;
const float p_o30711_d_in2_x = 0.000000000;
const float p_o30711_d_in2_y = 0.000000000;
const float p_o30711_d_in2_z = 0.000000000;
const float p_o30715_in_min = 0.000000000;
const float p_o30715_in_max = 1.000000000;
const float p_o30715_out_min = -1.000000000;
const float p_o30715_out_max = 1.000000000;
const float seed_o30714 = 0.830266118;
const float seed_o30706 = 0.201535702;
const float p_o30706_in_min = 0.000000000;
const float p_o30706_in_max = 1.000000000;
const float p_o30706_out_max = 0.500000000;
const float p_o30586_amount1 = 9.000000000;
const float p_o30586_amount2 = 2.000000000;
const float p_o30586_amount3 = 5.000000000;
const float p_o30492_sides = 6.000000000;
const float p_o30492_radius = 0.030000000;
const float p_o30492_edge = 1.000000000;
const float p_o30804_default_in1 = 0.000000000;
const float p_o30804_default_in2 = 0.000000000;
const float p_o30803_in_min = 0.000000000;
const float p_o30803_in_max = 0.100000000;
const float p_o30803_out_min = 0.000000000;
const float p_o30803_out_max = 0.500000000;
const float p_o30802_in_min = 0.700000000;
const float p_o30802_in_max = 1.000000000;
const float p_o30802_out_min = 0.700000000;
const float p_o30802_out_max = 0.000000000;
float o29594_input_in(vec2 uv, float _seed_variation_) {
float o30708_0_1_f = (fract(elapsed_time*param_rnd(.9,1.7, (seed_o30708+fract(_seed_variation_))+0.420167)+param_rnd(0,1, (seed_o30708+fract(_seed_variation_))+0.123573)));
float o30707_0_clamp_false = smoothstep(0.0, 1.0, o30708_0_1_f);
float o30707_0_clamp_true = clamp(o30707_0_clamp_false, 0.0, 1.0);
float o30707_0_1_f = o30707_0_clamp_false;
vec4 o30703_0_1_rgba = vec4(vec3(p_o30703_out_min)+(vec4(vec3(o30707_0_1_f), 1.0).rgb-vec3(p_o30703_in_min))*vec3((p_o30703_out_max-(p_o30703_out_min))/(p_o30703_in_max-(p_o30703_in_min))), vec4(vec3(o30707_0_1_f), 1.0).a);
float o30705_0_clamp_false = sin((elapsed_time*1.2+param_rnd(0,10.0, (seed_o30705+fract(_seed_variation_))+-0.999990))*(param_rnd(0,10, (seed_o30705+fract(_seed_variation_))+17.841471)));
float o30705_0_clamp_true = clamp(o30705_0_clamp_false, 0.0, 1.0);
float o30705_0_2_f = o30705_0_clamp_false;
float o30704_0_clamp_false = cos((elapsed_time*1.2+param_rnd(0,10.0, (seed_o30704+fract(_seed_variation_))+-0.999990))*(param_rnd(0,10, (seed_o30704+fract(_seed_variation_))+17.841471)));
float o30704_0_clamp_true = clamp(o30704_0_clamp_false, 0.0, 1.0);
float o30704_0_2_f = o30704_0_clamp_false;
vec4 o30702_0_1_rgba = vec4(o30705_0_2_f, o30704_0_2_f, 0.0, 1.0);
vec3 o30714_0_rand = vec3(0.0);vec3 o30714_0_2_rgb = rand3( vec2( float((seed_o30714+fract(_seed_variation_))) + o30714_0_rand.x, rand( o30714_0_rand.yz ) ) );
vec4 o30715_0_1_rgba = vec4(vec3(p_o30715_out_min)+(vec4(o30714_0_2_rgb, 1.0).rgb-vec3(p_o30715_in_min))*vec3((p_o30715_out_max-(p_o30715_out_min))/(p_o30715_in_max-(p_o30715_in_min))), vec4(o30714_0_2_rgb, 1.0).a);
vec3 o30711_0_clamp_false = normalize(((o30715_0_1_rgba).rgb));
vec3 o30711_0_clamp_true = clamp(o30711_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o30711_0_1_rgb = o30711_0_clamp_false;
vec4 o30712_0_b = vec4(o30711_0_1_rgb, 1.0);
vec4 o30712_0_l;
float o30712_0_a;
o30712_0_l = vec4(vec3(o30708_0_1_f), 1.0);
o30712_0_a = p_o30712_amount1*1.0;
o30712_0_b = vec4(blend_multiply((uv), o30712_0_l.rgb, o30712_0_b.rgb, o30712_0_a*o30712_0_l.a), min(1.0, o30712_0_b.a+o30712_0_a*o30712_0_l.a));
vec4 o30712_0_2_rgba = o30712_0_b;
vec4 o30713_0_1_rgba = vec4(vec3(p_o30713_out_min)+(o30712_0_2_rgba.rgb-vec3(p_o30713_in_min))*vec3((p_o30713_out_max-(p_o30713_out_min))/(p_o30713_in_max-(p_o30713_in_min))), o30712_0_2_rgba.a);
vec4 o30709_0_b = o30703_0_1_rgba;
vec4 o30709_0_l;
float o30709_0_a;
o30709_0_l = o30702_0_1_rgba;
o30709_0_a = p_o30709_amount1*1.0;
o30709_0_b = vec4(blend_multiply((uv), o30709_0_l.rgb, o30709_0_b.rgb, o30709_0_a*o30709_0_l.a), min(1.0, o30709_0_b.a+o30709_0_a*o30709_0_l.a));
o30709_0_l = o30713_0_1_rgba;
o30709_0_a = p_o30709_amount2*1.0;
o30709_0_b = vec4(blend_additive((uv), o30709_0_l.rgb, o30709_0_b.rgb, o30709_0_a*o30709_0_l.a), min(1.0, o30709_0_b.a+o30709_0_a*o30709_0_l.a));
vec4 o30709_0_2_rgba = o30709_0_b;
float o30801_0_1_f = o30709_0_2_rgba.r;
float o30801_1_2_f = o30709_0_2_rgba.g;
vec4 o30706_0_1_rgba = vec4(vec3((param_rnd(1,4, (seed_o30706+fract(_seed_variation_))+34.841471)))+(vec4(vec3(o30707_0_1_f), 1.0).rgb-vec3(p_o30706_in_min))*vec3((p_o30706_out_max-((param_rnd(1,4, (seed_o30706+fract(_seed_variation_))+34.841471))))/(p_o30706_in_max-(p_o30706_in_min))), vec4(vec3(o30707_0_1_f), 1.0).a);
vec4 o30417_0 = textureLod(texture_2, (transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), 0.0);
vec4 o30511_0 = textureLod(texture_3, (transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), 0.0);
float o30492_0_1_f = shape_circle((transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), p_o30492_sides, p_o30492_radius*1.0, p_o30492_edge*1.0);
vec4 o30324_0 = textureLod(texture_4, (transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), 0.0);
vec4 o30586_0_b = o30417_0;
vec4 o30586_0_l;
float o30586_0_a;
o30586_0_l = o30511_0;
o30586_0_a = p_o30586_amount1*1.0;
o30586_0_b = vec4(blend_additive((transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), o30586_0_l.rgb, o30586_0_b.rgb, o30586_0_a*o30586_0_l.a), min(1.0, o30586_0_b.a+o30586_0_a*o30586_0_l.a));
o30586_0_l = vec4(vec3(o30492_0_1_f), 1.0);
o30586_0_a = p_o30586_amount2*1.0;
o30586_0_b = vec4(blend_additive((transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), o30586_0_l.rgb, o30586_0_b.rgb, o30586_0_a*o30586_0_l.a), min(1.0, o30586_0_b.a+o30586_0_a*o30586_0_l.a));
o30586_0_l = o30324_0;
o30586_0_a = p_o30586_amount3*1.0;
o30586_0_b = vec4(blend_additive((transform2_clamp(transform2((uv), vec2(p_o29592_translate_x*(2.0*o30801_0_1_f-1.0), p_o29592_translate_y*(2.0*o30801_1_2_f-1.0)), p_o29592_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29592_scale_x*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0), p_o29592_scale_y*(2.0*(dot((o30706_0_1_rgba).rgb, vec3(1.0))/3.0)-1.0))))), o30586_0_l.rgb, o30586_0_b.rgb, o30586_0_a*o30586_0_l.a), min(1.0, o30586_0_b.a+o30586_0_a*o30586_0_l.a));
vec4 o30586_0_2_rgba = o30586_0_b;
vec4 o29592_0_1_rgba = o30586_0_2_rgba;
vec4 o30803_0_1_rgba = vec4(vec3(p_o30803_out_min)+(vec4(vec3(o30707_0_1_f), 1.0).rgb-vec3(p_o30803_in_min))*vec3((p_o30803_out_max-(p_o30803_out_min))/(p_o30803_in_max-(p_o30803_in_min))), vec4(vec3(o30707_0_1_f), 1.0).a);
vec4 o30802_0_1_rgba = vec4(vec3(p_o30802_out_min)+(vec4(vec3(o30707_0_1_f), 1.0).rgb-vec3(p_o30802_in_min))*vec3((p_o30802_out_max-(p_o30802_out_min))/(p_o30802_in_max-(p_o30802_in_min))), vec4(vec3(o30707_0_1_f), 1.0).a);
float o30804_0_clamp_false = (dot((o30803_0_1_rgba).rgb, vec3(1.0))/3.0)*(dot((o30802_0_1_rgba).rgb, vec3(1.0))/3.0);
float o30804_0_clamp_true = clamp(o30804_0_clamp_false, 0.0, 1.0);
float o30804_0_1_f = o30804_0_clamp_false;
vec4 o29656_0_b = o29592_0_1_rgba;
vec4 o29656_0_l;
float o29656_0_a;
o29656_0_l = vec4(vec3(o30804_0_1_f), 1.0);
o29656_0_a = p_o29656_amount1*1.0;
o29656_0_b = vec4(blend_multiply((uv), o29656_0_l.rgb, o29656_0_b.rgb, o29656_0_a*o29656_0_l.a), min(1.0, o29656_0_b.a+o29656_0_a*o29656_0_l.a));
vec4 o29656_0_2_rgba = o29656_0_b;
return (dot((o29656_0_2_rgba).rgb, vec3(1.0))/3.0);
}
float b_o29594(vec2 uv, int count, float seed, float _seed_variation_) {
	float res = 0.0;
	for(int i=0; i < count; i++)
		res += o29594_input_in(uv,rand2(vec2(seed+float(i))).x);
	return res;
}const float p_o29627_default_in1 = 0.000000000;
const float p_o29627_default_in2 = 0.000000000;
const float p_o29626_sides = 6.000000000;
const float p_o29626_radius = 0.430000000;
const float p_o29626_edge = 1.000000000;
const float p_o29635_value = 0.630000000;
const float p_o29635_width = 0.440000000;
const float p_o29634_default_in1 = 0.000000000;
const float p_o29634_default_in2 = 0.000000000;
const float p_o29633_default_in1 = 0.000000000;
const float p_o29633_default_in2 = 0.000000000;
const float p_o29632_value = 0.500000000;
const float p_o29632_width = 0.800000000;
const float p_o29632_contrast = 0.000000000;
const float p_o29631_sides = 6.000000000;
const float p_o29631_radius = 2.000000000;
const float p_o29631_edge = 1.000000000;
const float p_o29639_cx = 0.000000000;
const float p_o29639_cy = 0.000000000;
const float p_o29638_translate_x = 0.000000000;
const float p_o29638_translate_y = 0.000000000;
const float p_o29638_rotate = 15.000000000;
const float p_o29638_scale_x = -1.000000000;
const float p_o29638_scale_y = 1.000000000;
const float p_o29630_radius = 5.100000000;
const float p_o29630_repeat = 1.000000000;
const float p_o29637_translate_x = 0.000000000;
const float p_o29637_translate_y = 0.000000000;
const float p_o29637_rotate = 0.000000000;
const float p_o29637_scale_x = 1.000000000;
const float p_o29637_scale_y = 1.000000000;
const float p_o29629_default_in1 = 0.611200000;
const float p_o29629_default_in2 = 0.000000000;
const float p_o29655_translate_x = 0.000000000;
const float p_o29640_sides = 6.000000000;
const float p_o29640_radius = 1.500000000;
const float p_o29640_edge = 1.000000000;
const float p_o30697_default_in1 = 0.000000000;
const float p_o30697_default_in2 = 0.000000000;
const float p_o30696_sides = 6.000000000;
const float p_o30696_radius = 1.110000000;
const float p_o30696_edge = 2.690000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o29615_0_1_f = shape_circle((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), p_o29615_sides, p_o29615_radius*1.0, p_o29615_edge*1.0);
float o29616_0_clamp_false = smoothstep(0.0, 1.0, o29615_0_1_f);
float o29616_0_clamp_true = clamp(o29616_0_clamp_false, 0.0, 1.0);
float o29616_0_1_f = o29616_0_clamp_false;
vec2 o29624_0_c = vec2(0.5+p_o29624_cx, 0.5+p_o29624_cy);float o29641_0_r = 0.5+(cos(p_o29641_rotate*0.01745329251)*((vec2(fract(p_o29600_repeat*atan((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).y-0.5, (swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29600_radius*length((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251))-vec2(0.5))))).x-0.5)+sin(p_o29641_rotate*0.01745329251)*((vec2(fract(p_o29600_repeat*atan((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).y-0.5, (swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29600_radius*length((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251))-vec2(0.5))))).y-0.5))/(cos(abs(mod(p_o29641_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o29641_0_1_rgba = o29641_gradient_gradient_fct(fract(o29641_0_r*p_o29641_repeat));
float o29620_0_clamp_false = p_o29620_default_in1/(dot((o29641_0_1_rgba).rgb, vec3(1.0))/3.0);
float o29620_0_clamp_true = clamp(o29620_0_clamp_false, 0.0, 1.0);
float o29620_0_2_f = o29620_0_clamp_false;
vec4 o30693_0 = textureLod(texture_1, ((fract(transform2((vec2(fract(p_o29600_repeat*atan((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).y-0.5, (swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251)).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29600_radius*length((swirl_tile_false((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29624_0_c, (elapsed_time*110.)*0.01745329251)+o29624_0_c), vec2(0.5+p_o29599_cx, 0.5+p_o29599_cy), p_o29599_radius, p_o29599_angle*0.01745329251))-vec2(0.5))))), vec2(p_o29621_translate_x*(2.0*1.0-1.0), p_o29621_translate_y*(2.0*1.0-1.0)), p_o29621_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29621_scale_x*(2.0*1.0-1.0), p_o29621_scale_y*(2.0*o29620_0_2_f-1.0)))))-vec2(p_o29654_translate_x, (elapsed_time*-.6))), 0.0);
float o29623_0_1_f = o30693_0.r;
vec4 o29654_0_1_rgba = vec4(vec3(o29623_0_1_f), 1.0);
vec4 o29621_0_1_rgba = o29654_0_1_rgba;
vec4 o29600_0_1_rgba = o29621_0_1_rgba;
vec4 o29599_0_1_rgba = o29600_0_1_rgba;
vec4 o29624_0_1_rgba = o29599_0_1_rgba;
float o29617_0_clamp_false = o29616_0_1_f-(dot((o29624_0_1_rgba).rgb, vec3(1.0))/3.0);
float o29617_0_clamp_true = clamp(o29617_0_clamp_false, 0.0, 1.0);
float o29617_0_1_f = o29617_0_clamp_false;
vec3 o29618_0_false = clamp((vec4(vec3(o29617_0_1_f), 1.0).rgb-vec3(p_o29618_value))/max(0.0001, p_o29618_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o29618_0_true = vec3(1.0)-o29618_0_false;vec4 o29618_0_1_rgba = vec4(o29618_0_false, vec4(vec3(o29617_0_1_f), 1.0).a);
vec4 o29601_0_1_rgba = o29601_gradient_gradient_fct(fract(p_o29601_repeat*1.41421356237*length(fract((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))))-vec2(0.5, 0.5))));
float o29614_0_clamp_false = (dot((o29618_0_1_rgba).rgb, vec3(1.0))/3.0)/(dot((o29601_0_1_rgba).rgb, vec3(1.0))/3.0);
float o29614_0_clamp_true = clamp(o29614_0_clamp_false, 0.0, 1.0);
float o29614_0_1_f = o29614_0_clamp_false;
float o29594_0_b = b_o29594((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), int(p_o29594_count), float((seed_o29594+fract(_seed_variation_))), _seed_variation_);float o29594_0_1_f = o29594_0_b;
vec4 o30698_0_b = o29618_0_1_rgba;
vec4 o30698_0_l;
float o30698_0_a;

o30698_0_l = vec4(vec3(o29614_0_1_f), 1.0);
o30698_0_a = p_o30698_amount1*1.0;
o30698_0_b = vec4(blend_multiply((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o30698_0_l.rgb, o30698_0_b.rgb, o30698_0_a*o30698_0_l.a), min(1.0, o30698_0_b.a+o30698_0_a*o30698_0_l.a));

o30698_0_l = vec4(vec3(o29594_0_1_f), 1.0);
o30698_0_a = p_o30698_amount2*1.0;
o30698_0_b = vec4(blend_additive((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o30698_0_l.rgb, o30698_0_b.rgb, o30698_0_a*o30698_0_l.a), min(1.0, o30698_0_b.a+o30698_0_a*o30698_0_l.a));

vec4 o30698_0_2_rgba = o30698_0_b;
float o29626_0_1_f = shape_circle((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), p_o29626_sides, p_o29626_radius*1.0, p_o29626_edge*1.0);
float o29627_0_clamp_false = smoothstep(0.0, 1.0, o29626_0_1_f);
float o29627_0_clamp_true = clamp(o29627_0_clamp_false, 0.0, 1.0);
float o29627_0_1_f = o29627_0_clamp_false;
float o29631_0_1_f = shape_circle((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), p_o29631_sides, p_o29631_radius*1.0, p_o29631_edge*1.0);
float o29632_0_step = clamp((o29631_0_1_f - (p_o29632_value))/max(0.0001, p_o29632_width)+0.5, 0.0, 1.0);
float o29632_0_false = clamp((min(o29632_0_step, 1.0-o29632_0_step) * 2.0) / (1.0 - p_o29632_contrast), 0.0, 1.0);
float o29632_0_true = 1.0-o29632_0_false;float o29632_0_1_f = o29632_0_false;
float o29633_0_clamp_false = smoothstep(0.0, 1.0, o29632_0_1_f);
float o29633_0_clamp_true = clamp(o29633_0_clamp_false, 0.0, 1.0);
float o29633_0_1_f = o29633_0_clamp_false;
vec2 o29639_0_c = vec2(0.5+p_o29639_cx, 0.5+p_o29639_cy);float o30699_0_1_f = (log2(distance((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c),vec2(.5)))/log2(.7091));
float o29641_2_r = 0.5+(cos(p_o29641_rotate*0.01745329251)*((vec2(fract(p_o29630_repeat*atan((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29630_radius*length((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))).x-0.5)+sin(p_o29641_rotate*0.01745329251)*((vec2(fract(p_o29630_repeat*atan((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29630_radius*length((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))).y-0.5))/(cos(abs(mod(p_o29641_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o29641_0_3_rgba = o29641_gradient_gradient_fct(fract(o29641_2_r*p_o29641_repeat));
float o29629_0_clamp_false = p_o29629_default_in1/(dot((o29641_0_3_rgba).rgb, vec3(1.0))/3.0);
float o29629_0_clamp_true = clamp(o29629_0_clamp_false, 0.0, 1.0);
float o29629_0_2_f = o29629_0_clamp_false;
vec4 o30693_1 = textureLod(texture_1, ((fract(transform2((vec2(fract(p_o29630_repeat*atan((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0)))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o29630_radius*length((transform2((rotate((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0))))-o29639_0_c, (elapsed_time*150.)*0.01745329251)+o29639_0_c), vec2(p_o29638_translate_x*(2.0*1.0-1.0), p_o29638_translate_y*(2.0*1.0-1.0)), p_o29638_rotate*0.01745329251*(2.0*o30699_0_1_f-1.0), vec2(p_o29638_scale_x*(2.0*1.0-1.0), p_o29638_scale_y*(2.0*1.0-1.0))))-vec2(0.5))))), vec2(p_o29637_translate_x*(2.0*1.0-1.0), p_o29637_translate_y*(2.0*1.0-1.0)), p_o29637_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o29637_scale_x*(2.0*1.0-1.0), p_o29637_scale_y*(2.0*o29629_0_2_f-1.0)))))-vec2(p_o29655_translate_x, (elapsed_time*1.5))), 0.0);
float o29623_1_3_f = o30693_1.g;
vec4 o29655_0_1_rgba = vec4(vec3(o29623_1_3_f), 1.0);
vec4 o29637_0_1_rgba = o29655_0_1_rgba;
vec4 o29630_0_1_rgba = o29637_0_1_rgba;
vec4 o29638_0_1_rgba = o29630_0_1_rgba;
vec4 o29639_0_1_rgba = o29638_0_1_rgba;
float o29634_0_clamp_false = o29633_0_1_f-(dot((o29639_0_1_rgba).rgb, vec3(1.0))/3.0);
float o29634_0_clamp_true = clamp(o29634_0_clamp_false, 0.0, 1.0);
float o29634_0_1_f = o29634_0_clamp_false;
vec3 o29635_0_false = clamp((vec4(vec3(o29634_0_1_f), 1.0).rgb-vec3(p_o29635_value))/max(0.0001, p_o29635_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o29635_0_true = vec3(1.0)-o29635_0_false;vec4 o29635_0_1_rgba = vec4(o29635_0_false, vec4(vec3(o29634_0_1_f), 1.0).a);
float o29640_0_1_f = shape_circle((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), p_o29640_sides, p_o29640_radius*1.0, p_o29640_edge*1.0);
float o30696_0_1_f = shape_circle((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), p_o30696_sides, p_o30696_radius*1.0, p_o30696_edge*1.0);
float o30697_0_clamp_false = smoothstep(0.0, 1.0, o30696_0_1_f);
float o30697_0_clamp_true = clamp(o30697_0_clamp_false, 0.0, 1.0);
float o30697_0_1_f = o30697_0_clamp_false;
vec4 o29628_0_b = o30698_0_2_rgba;
vec4 o29628_0_l;
float o29628_0_a;

o29628_0_l = vec4(vec3(o29627_0_1_f), 1.0);
o29628_0_a = p_o29628_amount1*1.0;
o29628_0_b = vec4(blend_additive((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o29628_0_l.rgb, o29628_0_b.rgb, o29628_0_a*o29628_0_l.a), min(1.0, o29628_0_b.a+o29628_0_a*o29628_0_l.a));

o29628_0_l = o30698_0_2_rgba;
o29628_0_a = p_o29628_amount2*1.0;
o29628_0_b = vec4(blend_additive((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o29628_0_l.rgb, o29628_0_b.rgb, o29628_0_a*o29628_0_l.a), min(1.0, o29628_0_b.a+o29628_0_a*o29628_0_l.a));

o29628_0_l = o29635_0_1_rgba;
o29628_0_a = p_o29628_amount3*o29640_0_1_f;
o29628_0_b = vec4(blend_additive((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o29628_0_l.rgb, o29628_0_b.rgb, o29628_0_a*o29628_0_l.a), min(1.0, o29628_0_b.a+o29628_0_a*o29628_0_l.a));

o29628_0_l = vec4(vec3(o30697_0_1_f), 1.0);
o29628_0_a = p_o29628_amount4*1.0;
o29628_0_b = vec4(blend_additive((transform2((uv), vec2(p_o30695_translate_x*(2.0*1.0-1.0), p_o30695_translate_y*(2.0*1.0-1.0)), p_o30695_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o30695_scale_x*(2.0*1.0-1.0), p_o30695_scale_y*(2.0*1.0-1.0)))), o29628_0_l.rgb, o29628_0_b.rgb, o29628_0_a*o29628_0_l.a), min(1.0, o29628_0_b.a+o29628_0_a*o29628_0_l.a));

vec4 o29628_0_2_rgba = o29628_0_b;
vec3 o29593_0_clamp_false = ((o29628_0_2_rgba).rgb)*vec3(p_o29593_d_in2_x, p_o29593_d_in2_y, p_o29593_d_in2_z);
vec3 o29593_0_clamp_true = clamp(o29593_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o29593_0_2_rgb = o29593_0_clamp_false;
vec3 o29619_0_clamp_false = pow(o29593_0_2_rgb,vec3(p_o29619_d_in2_x, p_o29619_d_in2_y, p_o29619_d_in2_z));
vec3 o29619_0_clamp_true = clamp(o29619_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o29619_0_2_rgb = o29619_0_clamp_false;
vec3 o29625_0_clamp_false = o29619_0_2_rgb/vec3(p_o29625_d_in2_x, p_o29625_d_in2_y, p_o29625_d_in2_z);
vec3 o29625_0_clamp_true = clamp(o29625_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o29625_0_2_rgb = o29625_0_clamp_false;
vec4 o30695_0_1_rgba = vec4(o29625_0_2_rgb, 1.0);

	vec4 color_tex = o30695_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb*paleta;
	ALPHA = color_tex.a*smoothstep(0.0,step1,color_tex.r);

}
