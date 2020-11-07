#version 300 es
 
in highp vec2 v_texCoord;

// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision highp float;
 
uniform float u_time;
uniform vec2 u_dims;


// we need to declare an output for the fragment shader
out vec4 outColor;

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sdf(vec2 p)
{
    // float c1 = length(p-vec2(0.1,0.0))-0.1*sin(u_time/1000.0);
    // float c2 = length(p-vec2(-0.01,0.0))-0.14*-sin(u_time/500.0);

    vec2 r = p;
    {
      float ang = u_time/1000.0;
      r = mat2(cos(ang), -sin(ang),
               sin(ang), cos(ang)) * r;
    }


    float anglePer = 6.283185/3.0;
    float sector = round(atan(r.y,r.x)/anglePer);
    // float sector = atan(r.y,r.x)/anglePer;

    float ang = sector * anglePer;

    vec2 q = r;
    q = mat2(cos(ang), -sin(ang),
             sin(ang), cos(ang)) * q;


    float c1 = length(q-vec2(0.2,0.0))-0.055*((sin(u_time/1000.0)+1.0));//-mod(sector,2.0)*0.01;
    float c2 = length(p)-0.1*(sin(u_time/400.0)+1.0)-0.1;

    return smin(c1,c2, 0.1);
    // return p.x;
}


// https://www.shadertoy.com/view/ll2GD3
vec3 palette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d)
{
    t = clamp(t, 0., 1.);
    return a + b*cos(6.28318*(c*t+d));
}

vec3 shade(float sd)
{
    // float maxDist = 2.0;
    // vec3 palCol = palette(clamp(0.5-sd*0.4, -maxDist,maxDist), 
    //                    vec3(0.6,0.3,0.1),vec3(0.6,0.7,0.1),vec3(0.2,0.2,0.8),vec3(0.2,0.2,0.8));
    
    vec3 col = mix(vec3(1,1,0), vec3(0,1,1), sd+0.3);
    col = mix(col, vec3 (0,0,0),sd+0.2);
    col= mix(vec3(0,0,0),col, sd+0.7);
    
    // Darken around surface
	  col = mix(col, col*1.0-exp(-10.0*abs(sd)), 0.4);
	  // repeating lines
    col *= 0.8 + 0.2*cos(550.0*sd);
    // White outline at surface
    col = mix(col, vec3(0.9), 1.0-smoothstep(0.0,0.01,abs(sd)));
    
    return col;
}


void main() {
  vec2 pos = v_texCoord - vec2(0.5,0.5);
  pos.x *= u_dims.x/u_dims.y;


  // signed distance for scene
  float sd = sdf(pos);
  // compute signed distance to a colour
  vec3 col = shade(sd);

  // float circ = length(pos) < 0.3? 1.0 : 0.0;
  // outColor = vec4(1,circ,0,1);
  
  outColor = vec4(col, 1.0);
}