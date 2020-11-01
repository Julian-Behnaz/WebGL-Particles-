#version 300 es
 
in highp vec2 v_texCoord;

// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;
 
uniform float u_time;
uniform float u_windAmp;


// we need to declare an output for the fragment shader
out vec4 outColor;

float bezier(float t, float a, float b, float c, float d) {
  return (1.0-t)*(1.0-t)*(1.0-t)*a +
         3.0*(1.0-t)*(1.0-t)*t*b +
         3.0*(1.0-t)*t*t*c +
         t*t*t * d;
}

float linMap(float in1, float in2, float out1, float out2, float inV) {
  return out1 + ((inV-in1)/(in2-in1))*(out2 - out1);
}


void main() {
  float interval = 0.1;
  float w = mod(v_texCoord.x, interval);
  float frac = linMap(0.0, 40.0, 0.0, 1.0, u_windAmp);
  frac = 1.0-clamp((bezier(frac,1.0,0.1,0.2,0.0)),0.0,1.0);
  float freq = 1.0 - frac;
  // float freq = 1.0;

  float circSize = 0.1+frac*2.0;
  float distFromCenter = length(v_texCoord - vec2(0.5)) * 1.0/0.707;
  float circ = 1.0 - smoothstep(circSize - 0.1, circSize, distFromCenter);
  vec4 circCol = vec4(circ,circ,circ,1) * vec4(0.8,0.8,0.5,1);
  float glowSize = 0.8;
  vec4 glowCol = vec4(1.0 - smoothstep(circSize*glowSize - 0.1, circSize*glowSize, distFromCenter));
  vec4 innerCol = vec4((1.0-distFromCenter) * sin(100.0*(atan((v_texCoord.y-0.5)*0.5, (v_texCoord.x-0.5)*0.5)+3.14)/6.28)) * vec4(0.8,0.8,0.5,1);

  float band = w<interval*freq? 0.0 : 1.0 ;
  vec4 bandCol = vec4(band,0,0,1);

  outColor = /*bandCol + */ circCol + glowCol + innerCol;
}