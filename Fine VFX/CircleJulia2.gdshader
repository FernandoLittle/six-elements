shader_type spatial;

render_mode unshaded, blend_add;
render_mode cull_disabled;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
uniform float Julia=0.0;
uniform float alpha=1.0;
uniform vec3 paleta= vec3(1.0, 1.0, 1.0);
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
vec2 sdLine(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p-a, ba = b-a;
	float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
	return vec2(length(pa-ba*h), h);
}
float ThickLine(vec2 uv, vec2 posA, vec2 posB, float radiusInv)
{
	return clamp(1.1-20.0*sdLine(uv, posA, posB).x, 0.0, 1.0);
}
// makes a rune in the 0..1 uv space. Seed is which rune to draw.
// passes back gray in x and derivates for lighting in yz
float Rune(vec2 uv, float s) {
	float finalLine = 0.0;
	vec2 seed = floor(uv)-rand2(vec2(s));
	uv = fract(uv);
	for (int i = 0; i < 4; i++)	// number of strokes
	{
		vec2 posA = rand2(floor(seed+0.5));
		vec2 posB = rand2(floor(seed+1.5));
		seed += 2.0;
		// expand the range and mod it to get a nicely distributed random number - hopefully. :)
		posA = fract(posA * 128.0);
		posB = fract(posB * 128.0);
		// each rune touches the edge of its box on all 4 sides
		if (i == 0) posA.y = 0.0;
		if (i == 1) posA.x = 0.999;
		if (i == 2) posA.x = 0.0;
		if (i == 3) posA.y = 0.999;
		// snap the random line endpoints to a grid 2x3
		vec2 snaps = vec2(2.0, 3.0);
		posA = (floor(posA * snaps) + 0.5) / snaps;	// + 0.5 to center it in a grid cell
		posB = (floor(posB * snaps) + 0.5) / snaps;
		//if (distance(posA, posB) < 0.0001) continue;	// eliminate dots.
		// Dots (degenerate lines) are not cross-GPU safe without adding 0.001 - divide by 0 error.
		finalLine = max(finalLine, ThickLine(uv, posA, posB + 0.001, 20.0));
	}
	return finalLine;
}
const float p_o1422595_default_in1 = 0.000000000;
const float p_o1422595_default_in2 = 0.000000000;
const float p_o1123255_default_in1 = 0.000000000;
const float p_o1123255_default_in2 = 0.000000000;
const float p_o1073048_default_in1 = 0.000000000;
const float p_o1073048_default_in2 = 0.000000000;
const float p_o938539_default_in1 = 0.000000000;
const float p_o938539_default_in2 = 0.000000000;
const float p_o748563_default_in1 = 0.000000000;
const float p_o748563_default_in2 = 0.000000000;
const float p_o1317292_default_in1 = 0.000000000;
const float p_o1317292_default_in2 = 0.000000000;
const float p_o1312793_translate_x = 0.000000000;
const float p_o1312793_translate_y = 0.000000000;
const float p_o1312793_rotate = 0.000000000;
const float p_o1312793_scale_x = 1.149999976;
const float p_o1312793_scale_y = 1.149999976;
const float p_o468448_translate_x = 0.000000000;
const float p_o468448_translate_y = 0.000000000;
const float p_o468448_rotate = 0.000000000;
const float p_o468448_scale_x = 1.000000000;
const float p_o468448_scale_y = 1.000000000;
const float p_o454769_value = 0.150000000;
const float p_o454769_width = 0.040000000;
const float p_o454769_contrast = 0.410000000;
const float p_o449171_sides = 7.000000000;
const float p_o449171_radius = 0.910000000;
const float p_o449171_edge = 1.000000000;
const float p_o470748_default_in1 = 0.000000000;
const float p_o470748_default_in2 = 0.000000000;
const float p_o295881_translate_x = 0.000000000;
const float p_o295881_translate_y = 0.000000000;
const float p_o295881_rotate = 0.000000000;
const float p_o295881_scale_x = 2.000000000;
const float p_o295881_scale_y = 2.000000000;
const float seed_o206102 = 0.000000000;
const float p_o206102_count = 4.000000000;
const float p_o206102_rings = 1.000000000;
const float p_o206102_scale_x = 1.000000000;
const float p_o206102_scale_y = 1.000000000;
const float p_o206102_radius = 0.320000000;
const float p_o206102_spiral = 0.000000000;
const float p_o206102_i_rotate = 1.000000000;
const float p_o206102_i_scale = 0.000000000;
const float p_o206102_rotate = 0.000000000;
const float p_o206102_scale = 0.000000000;
const float p_o206102_value = 0.000000000;
const float p_o197584_translate_x = 0.000000000;
const float p_o197584_translate_y = -0.715000000;
const float p_o197584_rotate = 0.000000000;
const float p_o197584_scale_x = 1.410000000;
const float p_o197584_scale_y = 1.015000000;
const float p_o357041_default_in1 = 0.000000000;
const float p_o357041_default_in2 = 0.000000000;
const float p_o66313_default_in1 = 0.000000000;
const float p_o66313_default_in2 = 0.000000000;
const float p_o141825_value = 0.270000000;
const float p_o141825_width = 0.010000000;
const float p_o141825_contrast = 0.480000000;
const float p_o136102_sides = 5.000000000;
const float p_o136102_radius = 1.000000000;
const float p_o136102_edge = 1.000000000;
const float p_o175112_translate_x = 0.000000000;
const float p_o175112_translate_y = 0.040000000;
const float p_o175112_rotate = 0.000000000;
const float p_o175112_scale_x = 2.850000000;
const float p_o175112_scale_y = 1.690000000;
const float p_o169653_sides = 4.000000000;
const float p_o169653_radius = 1.000000000;
const float p_o169653_edge = 0.000000000;
const float p_o350808_translate_x = -0.605000000;
const float p_o350808_translate_y = 0.750000000;
const float p_o350808_rotate = 0.000000000;
const float p_o350808_scale_x = 1.000000000;
const float p_o350808_scale_y = 1.000000000;
const float p_o402153_default_in2 = -0.600000024;
float o206102_input_in(vec2 uv, float _seed_variation_) {
float o136102_0_1_f = shape_star((transform2((uv), vec2(p_o197584_translate_x*(2.0*1.0-1.0), p_o197584_translate_y*(2.0*1.0-1.0)), p_o197584_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o197584_scale_x*(2.0*1.0-1.0), p_o197584_scale_y*(2.0*1.0-1.0)))), p_o136102_sides, p_o136102_radius*1.0, p_o136102_edge*1.0);
float o141825_0_step = clamp((o136102_0_1_f - (p_o141825_value))/max(0.0001, p_o141825_width)+0.5, 0.0, 1.0);
float o141825_0_false = clamp((min(o141825_0_step, 1.0-o141825_0_step) * 2.0) / (1.0 - p_o141825_contrast), 0.0, 1.0);
float o141825_0_true = 1.0-o141825_0_false;float o141825_0_1_f = o141825_0_false;
float o169653_0_1_f = shape_polygon((transform2((transform2((uv), vec2(p_o197584_translate_x*(2.0*1.0-1.0), p_o197584_translate_y*(2.0*1.0-1.0)), p_o197584_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o197584_scale_x*(2.0*1.0-1.0), p_o197584_scale_y*(2.0*1.0-1.0)))), vec2(p_o175112_translate_x*(2.0*1.0-1.0), p_o175112_translate_y*(2.0*1.0-1.0)), p_o175112_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o175112_scale_x*(2.0*1.0-1.0), p_o175112_scale_y*(2.0*1.0-1.0)))), p_o169653_sides, p_o169653_radius*1.0, p_o169653_edge*1.0);
vec4 o175112_0_1_rgba = vec4(vec3(o169653_0_1_f), 1.0);
float o66313_0_clamp_false = o141825_0_1_f-(dot((o175112_0_1_rgba).rgb, vec3(1.0))/3.0);
float o66313_0_clamp_true = clamp(o66313_0_clamp_false, 0.0, 1.0);
float o66313_0_1_f = o66313_0_clamp_false;
float o402153_0_clamp_false = (Julia)+p_o402153_default_in2;
float o402153_0_clamp_true = clamp(o402153_0_clamp_false, 0.0, 1.0);
float o402153_0_2_f = o402153_0_clamp_false;
float o169653_0_4_f = shape_polygon((transform2((transform2((uv), vec2(p_o197584_translate_x*(2.0*1.0-1.0), p_o197584_translate_y*(2.0*1.0-1.0)), p_o197584_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o197584_scale_x*(2.0*1.0-1.0), p_o197584_scale_y*(2.0*1.0-1.0)))), vec2(p_o350808_translate_x*(2.0*o402153_0_2_f-1.0), p_o350808_translate_y*(2.0*1.0-1.0)), p_o350808_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o350808_scale_x*(2.0*1.0-1.0), p_o350808_scale_y*(2.0*1.0-1.0)))), p_o169653_sides, p_o169653_radius*1.0, p_o169653_edge*1.0);
vec4 o350808_0_1_rgba = vec4(vec3(o169653_0_4_f), 1.0);
float o357041_0_clamp_false = o66313_0_1_f-(dot((o350808_0_1_rgba).rgb, vec3(1.0))/3.0);
float o357041_0_clamp_true = clamp(o357041_0_clamp_false, 0.0, 1.0);
float o357041_0_1_f = o357041_0_clamp_false;
vec4 o197584_0_1_rgba = vec4(vec3(o357041_0_1_f), 1.0);
return (dot((o197584_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o206102_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o206102(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o206102_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o206102_radius*mix(rings_distance, spiral_distance, p_o206102_spiral)*vec2(cos(a), sin(a));
		float mask = o206102_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o206102_rotate * 0.01745329251 + (a+1.57079632679) * p_o206102_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o206102_i_scale);
			pv /= vec2(p_o206102_scale_x, p_o206102_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o206102_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o206102_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o206102_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float seed_o693436 = 0.000000000;
const float p_o693436_count = 4.000000000;
const float p_o693436_rings = 1.000000000;
const float p_o693436_scale_x = 1.000000000;
const float p_o693436_scale_y = 1.000000000;
const float p_o693436_radius = 0.360000000;
const float p_o693436_spiral = -0.010000000;
const float p_o693436_i_rotate = 0.010000000;
const float p_o693436_i_scale = 0.000000000;
const float p_o693436_rotate = 1.100000000;
const float p_o693436_scale = 0.000000000;
const float p_o693436_value = 0.000000000;
const float p_o684510_translate_x = 0.000000000;
const float p_o684510_translate_y = 0.000000000;
const float p_o684510_rotate = 0.000000000;
const float p_o684510_scale_x = 0.055000000;
const float p_o684510_scale_y = 0.055000000;
const float p_o957315_default_in1 = 0.000000000;
const float p_o957315_default_in2 = 0.000000000;
const float p_o777461_value = 0.250000000;
const float p_o777461_width = 0.180000000;
const float p_o777461_contrast = 0.080000000;
const float p_o882942_sides = 5.000000000;
const float p_o882942_radius = 0.840000000;
const float p_o882942_edge = 1.000000000;
const float p_o959343_sides = 6.000000000;
const float p_o959343_radius = 0.370000000;
const float p_o959343_edge = 0.700000000;
float o693436_input_in(vec2 uv, float _seed_variation_) {
float o882942_0_1_f = shape_circle((transform2((uv), vec2(p_o684510_translate_x*(2.0*1.0-1.0), p_o684510_translate_y*(2.0*1.0-1.0)), p_o684510_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o684510_scale_x*(2.0*1.0-1.0), p_o684510_scale_y*(2.0*1.0-1.0)))), p_o882942_sides, p_o882942_radius*1.0, p_o882942_edge*1.0);
float o777461_0_step = clamp((o882942_0_1_f - (p_o777461_value))/max(0.0001, p_o777461_width)+0.5, 0.0, 1.0);
float o777461_0_false = clamp((min(o777461_0_step, 1.0-o777461_0_step) * 2.0) / (1.0 - p_o777461_contrast), 0.0, 1.0);
float o777461_0_true = 1.0-o777461_0_false;float o777461_0_1_f = o777461_0_false;
float o959343_0_1_f = shape_circle((transform2((uv), vec2(p_o684510_translate_x*(2.0*1.0-1.0), p_o684510_translate_y*(2.0*1.0-1.0)), p_o684510_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o684510_scale_x*(2.0*1.0-1.0), p_o684510_scale_y*(2.0*1.0-1.0)))), p_o959343_sides, p_o959343_radius*1.0, p_o959343_edge*1.0);
float o957315_0_clamp_false = o777461_0_1_f+o959343_0_1_f;
float o957315_0_clamp_true = clamp(o957315_0_clamp_false, 0.0, 1.0);
float o957315_0_1_f = o957315_0_clamp_false;
vec4 o684510_0_1_rgba = vec4(vec3(o957315_0_1_f), 1.0);
return (dot((o684510_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o693436_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o693436(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o693436_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o693436_radius*mix(rings_distance, spiral_distance, p_o693436_spiral)*vec2(cos(a), sin(a));
		float mask = o693436_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o693436_rotate * 0.01745329251 + (a+1.57079632679) * p_o693436_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o693436_i_scale);
			pv /= vec2(p_o693436_scale_x, p_o693436_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o693436_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o693436_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o693436_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o1483078_translate_x = 0.000000000;
const float p_o1483078_translate_y = 0.000000000;
const float p_o1483078_scale_x = 1.000000000;
const float p_o1483078_scale_y = 1.000000000;
const float p_o1397306_radius = 1.670000000;
const float p_o1397306_repeat = 8.000000000;
const float p_o1400361_translate_x = 0.000000000;
const float p_o1400361_translate_y = 0.000000000;
const float p_o1400361_rotate = 0.000000000;
const float p_o1400361_scale_x = 1.000000000;
const float p_o1400361_scale_y = 0.040000000;
const float seed_o1393550 = 0.000000000;
const float p_o1393550_columns = 12.000000000;
const float p_o1393550_rows = 1.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o449171_0_1_f = shape_circle((transform2_clamp(transform2((transform2_clamp(transform2((uv), vec2(p_o1312793_translate_x*(2.0*1.0-1.0), p_o1312793_translate_y*(2.0*1.0-1.0)), p_o1312793_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o1312793_scale_x*(2.0*1.0-1.0), p_o1312793_scale_y*(2.0*1.0-1.0))))), vec2(p_o468448_translate_x*(2.0*1.0-1.0), p_o468448_translate_y*(2.0*1.0-1.0)), p_o468448_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o468448_scale_x*(2.0*1.0-1.0), p_o468448_scale_y*(2.0*1.0-1.0))))), p_o449171_sides, p_o449171_radius*1.0, p_o449171_edge*1.0);
float o454769_0_step = clamp((o449171_0_1_f - (p_o454769_value))/max(0.0001, p_o454769_width)+0.5, 0.0, 1.0);
float o454769_0_false = clamp((min(o454769_0_step, 1.0-o454769_0_step) * 2.0) / (1.0 - p_o454769_contrast), 0.0, 1.0);
float o454769_0_true = 1.0-o454769_0_false;float o454769_0_1_f = o454769_0_false;
vec4 o468448_0_1_rgba = vec4(vec3(o454769_0_1_f), 1.0);
vec4 o1312793_0_1_rgba = o468448_0_1_rgba;
float o449171_0_4_f = shape_circle((transform2_clamp(transform2((uv), vec2(p_o468448_translate_x*(2.0*1.0-1.0), p_o468448_translate_y*(2.0*1.0-1.0)), p_o468448_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o468448_scale_x*(2.0*1.0-1.0), p_o468448_scale_y*(2.0*1.0-1.0))))), p_o449171_sides, p_o449171_radius*1.0, p_o449171_edge*1.0);
float o454769_2_step = clamp((o449171_0_4_f - (p_o454769_value))/max(0.0001, p_o454769_width)+0.5, 0.0, 1.0);
float o454769_2_false = clamp((min(o454769_2_step, 1.0-o454769_2_step) * 2.0) / (1.0 - p_o454769_contrast), 0.0, 1.0);
float o454769_2_true = 1.0-o454769_2_false;float o454769_0_3_f = o454769_2_false;
vec4 o468448_0_4_rgba = vec4(vec3(o454769_0_3_f), 1.0);
vec3 o206102_0_instance_uv = vec3(0.0);
vec4 o206102_0_rch = splatter_o206102((transform2_clamp(transform2((uv), vec2(p_o295881_translate_x*(2.0*1.0-1.0), p_o295881_translate_y*(2.0*1.0-1.0)), p_o295881_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o295881_scale_x*(2.0*1.0-1.0), p_o295881_scale_y*(2.0*1.0-1.0))))), int(p_o206102_count), int(p_o206102_rings), o206102_0_instance_uv, vec2(float((seed_o206102+fract(_seed_variation_)))), _seed_variation_);float o206102_0_1_f = o206102_0_rch.a;
vec4 o295881_0_1_rgba = vec4(vec3(o206102_0_1_f), 1.0);
float o470748_0_clamp_false = (dot((o468448_0_4_rgba).rgb, vec3(1.0))/3.0)+(dot((o295881_0_1_rgba).rgb, vec3(1.0))/3.0);
float o470748_0_clamp_true = clamp(o470748_0_clamp_false, 0.0, 1.0);
float o470748_0_1_f = o470748_0_clamp_false;
float o1317292_0_clamp_false = (dot((o1312793_0_1_rgba).rgb, vec3(1.0))/3.0)+o470748_0_1_f;
float o1317292_0_clamp_true = clamp(o1317292_0_clamp_false, 0.0, 1.0);
float o1317292_0_1_f = o1317292_0_clamp_false;
vec3 o693436_0_instance_uv = vec3(0.0);
vec4 o693436_0_rch = splatter_o693436((uv), int(p_o693436_count), int(p_o693436_rings), o693436_0_instance_uv, vec2(float((seed_o693436+fract(_seed_variation_)))), _seed_variation_);float o693436_0_1_f = o693436_0_rch.a;
float o748563_0_clamp_false = o1317292_0_1_f+o693436_0_1_f;
float o748563_0_clamp_true = clamp(o748563_0_clamp_false, 0.0, 1.0);
float o748563_0_1_f = o748563_0_clamp_false;
float o938539_0_clamp_false = o748563_0_1_f+p_o938539_default_in2;
float o938539_0_clamp_true = clamp(o938539_0_clamp_false, 0.0, 1.0);
float o938539_0_2_f = o938539_0_clamp_false;
float o1073048_0_clamp_false = p_o1073048_default_in1+o938539_0_2_f;
float o1073048_0_clamp_true = clamp(o1073048_0_clamp_false, 0.0, 1.0);
float o1073048_0_2_f = o1073048_0_clamp_false;
float o1123255_0_clamp_false = o1073048_0_2_f+p_o1123255_default_in2;
float o1123255_0_clamp_true = clamp(o1123255_0_clamp_false, 0.0, 1.0);
float o1123255_0_2_f = o1123255_0_clamp_false;
float o1393550_0_1_f = Rune(vec2(p_o1393550_columns, p_o1393550_rows)*(transform2_clamp(transform2((vec2(fract(p_o1397306_repeat*atan((transform2_clamp(transform2((uv), vec2(p_o1483078_translate_x*(2.0*1.0-1.0), p_o1483078_translate_y*(2.0*1.0-1.0)), (elapsed_time*5.0)*0.01745329251*(2.0*1.0-1.0), vec2(p_o1483078_scale_x*(2.0*1.0-1.0), p_o1483078_scale_y*(2.0*1.0-1.0))))).y-0.5, (transform2_clamp(transform2((uv), vec2(p_o1483078_translate_x*(2.0*1.0-1.0), p_o1483078_translate_y*(2.0*1.0-1.0)), (elapsed_time*5.0)*0.01745329251*(2.0*1.0-1.0), vec2(p_o1483078_scale_x*(2.0*1.0-1.0), p_o1483078_scale_y*(2.0*1.0-1.0))))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o1397306_radius*length((transform2_clamp(transform2((uv), vec2(p_o1483078_translate_x*(2.0*1.0-1.0), p_o1483078_translate_y*(2.0*1.0-1.0)), (elapsed_time*5.0)*0.01745329251*(2.0*1.0-1.0), vec2(p_o1483078_scale_x*(2.0*1.0-1.0), p_o1483078_scale_y*(2.0*1.0-1.0)))))-vec2(0.5))))), vec2(p_o1400361_translate_x*(2.0*1.0-1.0), p_o1400361_translate_y*(2.0*1.0-1.0)), p_o1400361_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o1400361_scale_x*(2.0*1.0-1.0), p_o1400361_scale_y*(2.0*1.0-1.0))))), float((seed_o1393550+fract(_seed_variation_))));
vec4 o1400361_0_1_rgba = vec4(vec3(o1393550_0_1_f), 1.0);
vec4 o1397306_0_1_rgba = o1400361_0_1_rgba;
vec4 o1483078_0_1_rgba = o1397306_0_1_rgba;
float o1422595_0_clamp_false = o1123255_0_2_f+(dot((o1483078_0_1_rgba).rgb, vec3(1.0))/3.0);
float o1422595_0_clamp_true = clamp(o1422595_0_clamp_false, 0.0, 1.0);
float o1422595_0_1_f = o1422595_0_clamp_false;

	vec4 color_tex = vec4(vec3(o1422595_0_1_f), 1.0);
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb*paleta;
	ALPHA = color_tex.a*alpha;

}
