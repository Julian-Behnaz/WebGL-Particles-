#version 300 es
 
in highp vec2 v_texCoord;

// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;
 
uniform float u_time;
uniform float u_windAmp;
uniform vec2 u_dims;
uniform float u_smooth;

// we need to declare an output for the fragment shader
out vec4 outColor;




float sdf(vec2 p) {
  //p -= vec2(0.5,0);
  //float s;
  //s = atan(p.y,p.x) * 4.0 + iTime*10.0;
  //return length(p)-(sin(s)+0.1)*0.3;
  float t=0.00005*u_time;
  float a = 0.0;
  vec2 q = mat2(sin(a), cos(a), cos(a), -sin(a)) * p;
    vec2 r= vec2 (q.x,q.y);
    return (sin(q.x * 50.0 * (cos((u_smooth*0.01+length(r)*0.9)*0.9)*0.5+1.0)));

  // return min(sin(p.x * 50.0 * (sin(u_smooth*0.01+length(p))*0.5+1.0)), 
  //            sin(q.y * 50.0+u_smooth+sin(length(p))));
}


void main() {
 vec2 pos = v_texCoord - vec2(0.5,0.5);
  pos.x *= u_dims.x/u_dims.y;
  pos*=5.0;
  vec3 col = sdf(pos)>0.0? vec3(1,1,1) : vec3(0,0,0);

  outColor= vec4(col,1);
}