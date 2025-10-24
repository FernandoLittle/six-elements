shader_type spatial;

render_mode unshaded, blend_add;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
uniform float parameter1 = 0.0;
uniform float parameter2 = 0.0;
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
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
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
const float p_o357702_default_in1 = 0.000000000;
const float p_o357702_default_in2 = 0.000000000;
const float p_o354199_sides = 6.000000000;
const float p_o354199_radius = 0.720000000;
const float p_o354199_edge = 0.000000000;
const float seed_o170937 = 0.000000000;
const float p_o170937_count = 8.000000000;
const float p_o170937_rings = 1.000000000;
const float p_o170937_scale_x = 1.000000000;
const float p_o170937_scale_y = 1.000000000;
const float p_o170937_radius = 0.310000000;
const float p_o170937_spiral = 0.000000000;
const float p_o170937_i_rotate = 1.000000000;
const float p_o170937_i_scale = 0.000000000;
const float p_o170937_rotate = 0.000000000;
const float p_o170937_scale = 0.000000000;
const float p_o170937_value = 0.000000000;
const float p_o35482_radius = 1.000000000;
const float p_o35482_repeat = 2.000000000;
const float p_o399869_default_in1 = 0.000000000;
const float p_o399869_default_in2 = 0.000000000;
const float p_o51989_translate_x = -0.045000000;
const float p_o51989_translate_y = 0.000000000;
const float p_o51989_scale_x = 1.640000000;
const float p_o51989_scale_y = 0.230000000;
const float p_o19717_value = 0.500000000;
const float p_o19717_width = 0.490000000;
const float p_o19717_contrast = 0.450000000;
const float p_o16359_sides = 25.000000000;
const float p_o16359_radius = 0.700000000;
const float p_o16359_edge = 0.770000000;
const float p_o397194_translate_x = 0.000000000;
const float p_o397194_translate_y = -0.430000000;
const float p_o397194_rotate = 0.000000000;
const float p_o397194_scale_x = 2.165000000;
const float p_o393415_sides = 4.000000000;
const float p_o393415_radius = 0.850000000;
const float p_o393415_edge = 0.100000000;
float o170937_input_in(vec2 uv, float _seed_variation_) {
float o16359_0_1_f = shape_polygon((transform2_clamp(transform2((vec2(fract(p_o35482_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o35482_radius*length((uv)-vec2(0.5))))), vec2(p_o51989_translate_x*(2.0*1.0-1.0), p_o51989_translate_y*(2.0*1.0-1.0)), (parameter1), vec2(p_o51989_scale_x*(2.0*1.0-1.0), p_o51989_scale_y*(2.0*1.0-1.0))))), p_o16359_sides, p_o16359_radius*1.0, p_o16359_edge*1.0);
float o19717_0_step = clamp((o16359_0_1_f - (p_o19717_value))/max(0.0001, p_o19717_width)+0.5, 0.0, 1.0);
float o19717_0_false = clamp((min(o19717_0_step, 1.0-o19717_0_step) * 2.0) / (1.0 - p_o19717_contrast), 0.0, 1.0);
float o19717_0_true = 1.0-o19717_0_false;float o19717_0_1_f = o19717_0_false;
vec4 o51989_0_1_rgba = vec4(vec3(o19717_0_1_f), 1.0);
float o393415_0_1_f = shape_polygon((transform2_clamp(transform2((vec2(fract(p_o35482_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o35482_radius*length((uv)-vec2(0.5))))), vec2(p_o397194_translate_x*(2.0*1.0-1.0), p_o397194_translate_y*(2.0*1.0-1.0)), p_o397194_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o397194_scale_x*(2.0*1.0-1.0), (sin(parameter2)*2.0)*(2.0*1.0-1.0))))), p_o393415_sides, p_o393415_radius*1.0, p_o393415_edge*1.0);
vec4 o397194_0_1_rgba = vec4(vec3(o393415_0_1_f), 1.0);
float o399869_0_clamp_false = (dot((o51989_0_1_rgba).rgb, vec3(1.0))/3.0)-(dot((o397194_0_1_rgba).rgb, vec3(1.0))/3.0);
float o399869_0_clamp_true = clamp(o399869_0_clamp_false, 0.0, 1.0);
float o399869_0_1_f = o399869_0_clamp_false;
vec4 o35482_0_1_rgba = vec4(vec3(o399869_0_1_f), 1.0);
return (dot((o35482_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o170937_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o170937(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o170937_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o170937_radius*mix(rings_distance, spiral_distance, p_o170937_spiral)*vec2(cos(a), sin(a));
		float mask = o170937_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o170937_rotate * 0.01745329251 + (a+1.57079632679) * p_o170937_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o170937_i_scale);
			pv /= vec2(p_o170937_scale_x, p_o170937_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o170937_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o170937_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o170937_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o354199_0_1_f = shape_circle((uv), p_o354199_sides, p_o354199_radius*1.0, p_o354199_edge*1.0);
vec3 o170937_0_instance_uv = vec3(0.0);
vec4 o170937_0_rch = splatter_o170937((uv), int(p_o170937_count), int(p_o170937_rings), o170937_0_instance_uv, vec2(float((seed_o170937+fract(_seed_variation_)))), _seed_variation_);float o170937_0_1_f = o170937_0_rch.a;
float o357702_0_clamp_false = o354199_0_1_f*o170937_0_1_f;
float o357702_0_clamp_true = clamp(o357702_0_clamp_false, 0.0, 1.0);
float o357702_0_1_f = o357702_0_clamp_false;

	vec4 color_tex = vec4(vec3(o357702_0_1_f), 1.0);
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



