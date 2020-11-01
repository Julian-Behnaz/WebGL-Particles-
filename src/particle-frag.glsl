#version 300 es
 
// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;

in highp vec2 v_texCoord;

in float v_particleIdxNorm; 
in float v_particleAmp; 
uniform float u_currWindAmp; 

// we need to declare an output for the fragment shader
out vec4 outColor;
 
void main() {
  vec2 tx = (v_texCoord-vec2(0.5,0.5))*2.0;
  float tl = 1.0-length(tx);

  outColor = vec4(1.0*v_particleAmp ,1.0*v_particleAmp,0,1);
}