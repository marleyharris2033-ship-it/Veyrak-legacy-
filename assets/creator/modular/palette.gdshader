shader_type canvas_item;
uniform int mode = 0;
uniform vec4 skin : source_color;
uniform vec4 accent : source_color;
uniform vec4 hair : source_color;
uniform vec4 eyes : source_color = vec4(0.95, 0.8, 0.45, 1.0);
void fragment() {
 vec4 c = texture(TEXTURE, UV);
 float light = dot(c.rgb,vec3(.299,.587,.114));
 if(mode==2) c.rgb = hair.rgb * (0.45 + light*1.8);
 else if(mode==1) {
  // Restrict tint to bright, cool eye pixels; preserve the drawn eyelids.
  bool eye_region = UV.x > .48 && UV.x < .96 && UV.y > .32 && UV.y < .52;
  bool eye_pixel = light > .68 && c.b >= c.r * .96;
  c.rgb = (eye_region && eye_pixel) ? eyes.rgb * light : skin.rgb * (light*1.45);
 }
 else {
  float saturation = max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
  if(c.r>c.b*1.35 && c.g>c.b*1.15 && saturation>.12) c.rgb=accent.rgb*(light*1.5);
  else if(light>.30 && saturation<.17) c.rgb=skin.rgb*(light*1.45);
 }
 COLOR = c;
}
