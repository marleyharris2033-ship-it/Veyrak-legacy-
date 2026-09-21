shader_type canvas_item;
uniform int mode = 0;
uniform vec4 skin : source_color;
uniform vec4 accent : source_color;
uniform vec4 hair : source_color;
void fragment() {
 vec4 c = texture(TEXTURE, UV);
 float light = dot(c.rgb,vec3(.299,.587,.114));
 if(mode==2) c.rgb = hair.rgb * (0.45 + light*1.8);
 else if(mode==1) c.rgb = skin.rgb * (light*1.45);
 else {
  float saturation = max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
  if(c.r>c.b*1.35 && c.g>c.b*1.15 && saturation>.12) c.rgb=accent.rgb*(light*1.5);
  else if(light>.30 && saturation<.17) c.rgb=skin.rgb*(light*1.45);
 }
 COLOR = c;
}
