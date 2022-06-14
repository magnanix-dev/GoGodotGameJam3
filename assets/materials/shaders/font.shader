shader_type canvas_item;
render_mode unshaded;

uniform bool x_or_y = false;
uniform vec4 from_color : hint_color;
uniform vec4 to_color : hint_color;
uniform float shadow_size : hint_range(0.0, 10.0);
uniform vec4 shadow_color : hint_color;

void fragment(){
	vec4 col;
	float intensity = 1.0;
	vec4 _texture = texture(TEXTURE, UV);
	float alpha = _texture.a;
	if(alpha > 0.0){
		float r;
		if(x_or_y){
			r = SCREEN_UV.x;
		}else{
			r = SCREEN_UV.y;
		}
		col = vec4(from_color.r * r + to_color.r * (intensity-r), from_color.g * r + to_color.g * (intensity-r), from_color.b * r + to_color.b * (intensity-r), alpha);
	}else{
		col = texture(TEXTURE, UV);
	}
	vec2 ps = TEXTURE_PIXEL_SIZE * shadow_size;

	vec4 shadow = vec4(shadow_color.rgb, texture(TEXTURE, UV - ps).a * shadow_color.a);
	vec4 _col = texture(TEXTURE, UV);

	COLOR = mix(shadow, _col, _col.a);
}