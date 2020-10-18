#version 300 es
 
in highp vec2 v_texCoord;

uniform sampler2D u_texture;

// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;
 
// we need to declare an output for the fragment shader
out vec4 outColor;
 
void main() {
  // Just set the output to a constant reddish-purple
//   outColor = vec4(vColor.x*4.0,vColor.y*2.,0,1);//vec4(1, 0, 0.5, 1);
  
  // vec4 color = texture(u_texture, v_texCoord);
  outColor = vec4(0,0,0,1);
}