#version 300 es
 
in highp vec2 v_texCoord;

uniform sampler2D u_texture;

// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;
 
uniform float u_time;


// we need to declare an output for the fragment shader
out vec4 outColor;
 

vec2 encode(float value) {
  // value is between -1 and 1
  // shift it to be between 0 and 1:
  float v = ((value + 1.0) * 0.5) * 65535.0;
  float hi = floor(v/256.0);
  float lo = v - (hi*256.0);
  return vec2(hi, lo)/255.0;
}

float decode(vec2 channels) {
  vec2 hilo = channels*255.0;
  float hi = hilo.x * 256.0;
  float lo = hilo.y;
  float res = (hi + lo)/65535.0;
  return (res - 0.5)*2.0;
}


void main() {
  // Just set the output to a constant reddish-purple
//   outColor = vec4(vColor.x*4.0,vColor.y*2.,0,1);//vec4(1, 0, 0.5, 1);
  
  vec4 color = texture(u_texture, v_texCoord);

  float particleIdx = (v_texCoord.y*255.0)*255.0 + (v_texCoord.x*255.0);

  vec2 pos = vec2(decode(color.rg), decode(color.ba));

  float l = length(pos);
  float tl = length(v_texCoord-vec2(0.5,0.5));
  vec2 tx = (v_texCoord-vec2(0.5,0.5))*2.0;
  // pos -= (  sin(tl*0.1+u_time*0.001))*0.001;
  pos = tx + sin(tl*20.0 + (u_time*0.001))*0.1;
  /// Do stuff!!!
  // pos.x += 0.01;

  outColor = vec4(encode(pos.x), encode(pos.y));
}