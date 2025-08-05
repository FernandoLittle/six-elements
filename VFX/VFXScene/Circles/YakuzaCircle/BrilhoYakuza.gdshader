shader_type spatial;

render_mode unshaded, blend_add;
uniform vec3 paleta = vec3(1.0, 1.0, 1.0);
uniform float greenpower: hint_range(0.0, 1.0, 0.01);
uniform float bluepower: hint_range(0.0, 1.0, 0.01);
uniform float redpower: hint_range(0.0, 1.0, 0.01);
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
float smin(float d1, float d2, float k) {
	float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) - k*h*(1.0-h);
}
float smax(float d1, float d2, float k) {
	float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) + k*h*(1.0-h);
}
float cellular_noise_2d_smooth(vec2 coord, vec2 size, float offset, float seed, float smoothness) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = smin(min_dist, dist,clamp(smoothness*0.5,0.0,1.0));
		}
	}
	return min_dist;
}
float fbm_2d_cellular_smooth(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed, float smoothness) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d_smooth(coord*size, size, offset, seed, smoothness);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
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
const float p_o465128_amount1 = 0.910000000;
const float p_o465126_amount1 = 1.090000000;
const float p_o465123_d_in1_x = 0.000000000;
const float p_o465123_d_in1_y = 10.000000000;
const float p_o465123_d_in1_z = 0.000000000;
const float p_o465123_d_in2_x = 2.760000000;
const float p_o465123_d_in2_y = 1.870000000;
const float p_o465123_d_in2_z = 1.000000000;
const float p_o465122_default_in1 = 0.000000000;
const float p_o465122_default_in2 = 0.000000000;
const float p_o465119_default_in1 = 0.000000000;
const float p_o465119_default_in2 = 5.890000000;
const float p_o465118_default_in1 = 0.000000000;
const float p_o465118_default_in2 = 4.330000000;
const float seed_o465101 = 0.000000000;
const float p_o465101_sx = 1.000000000;
const float p_o465101_sy = 1.000000000;
const float p_o465101_rotate = 0.000000000;
const float p_o465101_scale = 0.000000000;
const float seed_o465115 = 0.833631039;
const float p_o465115_sx = 16.000000000;
const float p_o465115_sy = 16.000000000;
const float p_o465115_f = 0.000000000;
const float p_o465115_i = 1.000000000;
const float p_o465115_p = 1.000000000;
const float p_o465115_s = 0.290000000;
vec4 o465101_input_in(vec2 uv, float _seed_variation_) {
float o465115_0_1_f = fbm_2d_cellular_smooth((uv),vec2(p_o465115_sx,p_o465115_sy),int(p_o465115_f),int(p_o465115_i),p_o465115_p,(elapsed_time*.2),(seed_o465115+fract(_seed_variation_)),p_o465115_s);
return vec4(vec3(o465115_0_1_f), 1.0);
}
const float p_o465102_repeat = 1.000000000;
const float p_o465102_gradient_0_pos = 0.000000000;
const vec4 p_o465102_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o465102_gradient_1_pos = 1.000000000;
const vec4 p_o465102_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o465102_gradient_gradient_fct(float x) {
  if (x < p_o465102_gradient_0_pos) {
    return p_o465102_gradient_0_col;
  } else if (x < p_o465102_gradient_1_pos) {
    return mix(p_o465102_gradient_0_col, p_o465102_gradient_1_col, ((x-p_o465102_gradient_0_pos)/(p_o465102_gradient_1_pos-p_o465102_gradient_0_pos)));
  }
  return p_o465102_gradient_1_col;
}
const float p_o465121_default_in1 = 0.000000000;
const float p_o465121_default_in2 = 0.000000000;
const float p_o465120_sides = 6.000000000;
const float p_o465120_radius = 1.330000000;
const float p_o465120_edge = 1.000000000;
const float p_o465127_d_in1_x = 0.150000000;
const float p_o465127_d_in1_y = 1.000000000;
const float p_o465127_d_in1_z = 0.000000000;
const float p_o465127_d_in2_x = 5.260000000;
const float p_o465127_d_in2_y = 1.300000000;
const float p_o465127_d_in2_z = 4.130000000;
const float p_o465125_default_in1 = 0.000000000;
const float p_o465125_default_in2 = 0.000000000;
const float p_o465124_sides = 6.000000000;
const float p_o465124_radius = 0.950000000;
const float p_o465124_edge = 1.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o465102_0_1_rgba = o465102_gradient_gradient_fct(fract(p_o465102_repeat*0.15915494309*atan((uv).y-0.5, (uv).x-0.5)));
vec3 o465101_0_map = ((o465102_0_1_rgba).rgb);
float o465101_0_rnd =  float((seed_o465101+fract(_seed_variation_)))+o465101_0_map.z;
vec4 o465101_0_1_rgba = o465101_input_in(get_from_tileset(1.0, o465101_0_rnd, custom_uv_transform(o465101_0_map.xy, vec2(p_o465101_sx, p_o465101_sy), p_o465101_rotate*0.01745329251, p_o465101_scale, vec2(o465101_0_map.z, float((seed_o465101+fract(_seed_variation_)))))), false ? o465101_0_rnd : 0.0);
float o465118_0_clamp_false = pow((dot((o465101_0_1_rgba).rgb, vec3(1.0))/3.0),p_o465118_default_in2);
float o465118_0_clamp_true = clamp(o465118_0_clamp_false, 0.0, 1.0);
float o465118_0_2_f = o465118_0_clamp_false;
float o465119_0_clamp_false = o465118_0_2_f*p_o465119_default_in2;
float o465119_0_clamp_true = clamp(o465119_0_clamp_false, 0.0, 1.0);
float o465119_0_2_f = o465119_0_clamp_false;
float o465120_0_1_f = shape_circle((uv), p_o465120_sides, p_o465120_radius*1.0, p_o465120_edge*1.0);
float o465121_0_clamp_false = smoothstep(0.0, 1.0, o465120_0_1_f);
float o465121_0_clamp_true = clamp(o465121_0_clamp_false, 0.0, 1.0);
float o465121_0_1_f = o465121_0_clamp_false;
float o465122_0_clamp_false = o465119_0_2_f*o465121_0_1_f;
float o465122_0_clamp_true = clamp(o465122_0_clamp_false, 0.0, 1.0);
float o465122_0_1_f = o465122_0_clamp_false;
vec3 o465123_0_clamp_false = pow(vec3(o465122_0_1_f),vec3(p_o465123_d_in2_x, p_o465123_d_in2_y, p_o465123_d_in2_z));
vec3 o465123_0_clamp_true = clamp(o465123_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o465123_0_2_rgb = o465123_0_clamp_false;
float o465124_0_1_f = shape_circle((uv), p_o465124_sides, p_o465124_radius*1.0, p_o465124_edge*1.0);
float o465125_0_clamp_false = smoothstep(0.0, 1.0, o465124_0_1_f);
float o465125_0_clamp_true = clamp(o465125_0_clamp_false, 0.0, 1.0);
float o465125_0_1_f = o465125_0_clamp_false;
vec3 o465127_0_clamp_false = pow(vec3(o465125_0_1_f),vec3(p_o465127_d_in2_x, p_o465127_d_in2_y, p_o465127_d_in2_z));
vec3 o465127_0_clamp_true = clamp(o465127_0_clamp_false, vec3(0.0), vec3(1.0));
vec3 o465127_0_2_rgb = o465127_0_clamp_false;
vec4 o465126_0_b = vec4(o465123_0_2_rgb, 1.0);
vec4 o465126_0_l;
float o465126_0_a;

o465126_0_l = vec4(o465127_0_2_rgb, 1.0);
o465126_0_a = p_o465126_amount1*1.0;
o465126_0_b = vec4(blend_additive((uv), o465126_0_l.rgb, o465126_0_b.rgb, o465126_0_a*o465126_0_l.a), min(1.0, o465126_0_b.a+o465126_0_a*o465126_0_l.a));

vec4 o465126_0_2_rgba = o465126_0_b;
vec4 o465128_0_b = o465126_0_2_rgba;
vec4 o465128_0_l;
float o465128_0_a;

o465128_0_l = o465126_0_2_rgba;
o465128_0_a = p_o465128_amount1*1.0;
o465128_0_b = vec4(blend_multiply((uv), o465128_0_l.rgb, o465128_0_b.rgb, o465128_0_a*o465128_0_l.a), min(1.0, o465128_0_b.a+o465128_0_a*o465128_0_l.a));

vec4 o465128_0_2_rgba = o465128_0_b;

	vec4 color_tex = o465128_0_2_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	float red= color_tex.r;
	float green= color_tex.g;
	float blue= color_tex.b;
	color_tex.r = mix(green,red,redpower);
	color_tex.g = mix(blue,green,greenpower);
	color_tex.b = mix(green,blue,bluepower);

	ALBEDO = color_tex.rgb*paleta;
	ALPHA = color_tex.a;

}
