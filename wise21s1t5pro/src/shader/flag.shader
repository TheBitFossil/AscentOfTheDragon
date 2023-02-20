shader_type spatial;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(-.2,-.1);

uniform vec2 time_scale = vec2(.3, .0);

uniform float face_distortion = .5;



void vertex(){
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
	
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	// Convert to -1.0, 1.0
	float texture_based_offset = noise * 2.0 - 1.0;
	// Dampening
	texture_based_offset *= UV.x;
	
	
	VERTEX.y += texture_based_offset;
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
	
}