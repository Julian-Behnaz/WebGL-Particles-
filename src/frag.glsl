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

// float sdf(vec2 p)
// {
//     // float c1 = length(p-vec2(0.1,0.0))-0.1*sin(u_time/1000.0);
//     // float c2 = length(p-vec2(-0.01,0.0))-0.14*-sin(u_time/500.0);

//     vec2 r = p;
//     {
//       float ang = u_time/1000.0;
//       r = mat2(cos(ang), -sin(ang),
//                sin(ang), cos(ang)) * r;
//     }


//     float anglePer = 6.283185/3.0;
//     float sector = round(atan(r.y,r.x)/anglePer);
//     // float sector = atan(r.y,r.x)/anglePer;

//     float ang = sector * anglePer;

//     vec2 q = r;
//     q = mat2(cos(ang), -sin(ang),
//              sin(ang), cos(ang)) * q;


//     float c1 = length(q-vec2(0.2,0.0))-0.055*((sin(u_time/1000.0)+1.0));//-mod(sector,2.0)*0.01;
//     float c2 = length(p)-0.1*(sin(u_time/400.0)+1.0)-0.1;

//     // return smin(c1,c2, 0.1);
//     // return p.x;
//     return smin(c1,c2, 0.1);
// }


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

float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

// float sdf(vec3 pos)
// {
//     float t1= sdSphere(pos-vec3(0.0, 0.0, 10.0), 3.0);
//     float t2 = sdSphere(pos-vec3(0.0, 4.0, 10.0), 1.0);
//     return smin(t1,t2,0.8);
// }

float sdCone( in vec3 p, in vec2 c, float h )
{
  // c is the sin/cos of the angle, h is height
  // Alternatively pass q instead of (c,h),
  // which is the point at the base in 2D
  vec2 q = h*vec2(c.x/c.y,-1.0);
    
  vec2 w = vec2( length(p.xz), p.y );
  vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
  vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
  float k = sign( q.y );
  float d = min(dot( a, a ),dot(b, b));
  float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
  return sqrt(d)*sign(s);
}


float sdf(vec3 p)
{
    // float c1 = length(p-vec2(0.1,0.0))-0.1*sin(u_time/1000.0);
    // float c2 = length(p-vec2(-0.01,0.0))-0.14*-sin(u_time/500.0);

    vec3 r = p;
    {
    float ang = u_time*0.001;
    // r = mat3(cos(ang), 0.0, sin(ang),
    //          0.0, 1.0, 0.0,
    //          -sin(ang), 0.0, cos(ang)) * r;

    r.xz = mat2(cos(ang), -sin(ang),
             sin(ang), cos(ang)) * r.xz;
    }


    float anglePer = 6.283185/20.0;
    float sector = round(atan(r.z,r.x)/anglePer);
    // float sector = atan(r.y,r.x)/anglePer;

    float ang = sector * anglePer;

    vec3 q = r;
    q.xz = mat2(cos(ang), -sin(ang),
             sin(ang), cos(ang)) * q.xz;


    float c1 = length(q-vec3(0.2,0.0,0.0))-0.055*((sin(u_time/1000.0)+1.0));//-mod(sector,2.0)*0.01;
    float c2 = length(p)-0.1*(sin(u_time/400.0)+1.0)-0.1;
    return smin(c1,c2, 0.1);
}

float castRay(vec3 rayOrigin, vec3 rayDir) {
    float distThreshold = 0.0001;
    int maxStepCount = 64;
    float totalDist = 0.0;
    for (int i = 0; i < maxStepCount; i++) {
        float currDist = sdf(rayOrigin + rayDir * totalDist);
        if (currDist < distThreshold * totalDist) { // TODO: why multiply here?
            return totalDist;
        }
        totalDist += currDist;
    }
    return -1.0;
}

// vec3 calcNormal(vec3 pos)
// {
//     // Center sample
//     float c = sdf(pos);
//     // Use offset samples to compute gradient / normal
//     vec2 eps_zero = vec2(0.001, 0.0);
//     return normalize(vec3( sdf(pos + eps_zero.xyy), sdf(pos + eps_zero.yxy), sdf(pos + eps_zero.yyx) ) - c);
// }
vec3 calcNormal(vec3 pos)
{
    vec2 eps_zero = vec2(0.01, 0.0);
    return normalize(vec3(sdf(pos + eps_zero.xyy) - sdf(pos - eps_zero.xyy),
    sdf(pos + eps_zero.yxy) - sdf(pos - eps_zero.yxy),
    sdf(pos + eps_zero.yyx) - sdf(pos - eps_zero.yyx)));
}

vec3 render(vec3 rayOrigin, vec3 camForward, vec3 rayDir)
{
    vec3 col;
    float t = castRay(rayOrigin, rayDir);
    
    if (t == -1.0) {
        col = vec3(0.0); 
    } else {
        // TODO: ???
        // vec3 objectSurfaceColour = vec3(0.4, 0.8, 0.1);
        // vec3 ambient = vec3(0.8, 0.021, 0.02);
        // col = ambient * objectSurfaceColour;
        // vec3 objectSurfaceColour = vec3(0.4, 0.8, 0.1);
        // vec3 objectSurfaceColour = vec3(0.5,0.5, 0.0);
        vec3 pos = rayOrigin + t * rayDir;

        vec3 lightDir = normalize(vec3(1.5, 1.5,0.0));
        vec3 surfaceNormal = calcNormal(pos);
        float ldot = max(dot(lightDir, surfaceNormal), 0.0);
        vec3 lightCol = vec3(1.0,1.0,0.0);
        // col = surfaceNormal * vec3(0.5) + vec3(0.5);
        // lightCol *= ldot;
        // vec3 ambientCol = vec3(0.7,0.5,0.7);
        // vec3 diffuseCol = objectSurfaceColour * (lightCol + ambientCol);
        vec3 baseColor = vec3(1, 0.6, 0);
        col = baseColor * lightCol * ldot;


        // Specular
        vec3 viewDirection = camForward;
        float specularPower = 8.5; // size
        float gloss = 7.0; // Strength
        vec3 h = (lightDir - viewDirection) / 2.;
        float s = pow( dot(surfaceNormal, h), specularPower) * gloss;
        col = baseColor * lightCol * ldot + s;

        // col = surfaceNormal * vec3(0.5) + vec3(0.5);


    }
    
    return col;
}


vec3 getCameraRayDir(vec2 pos, vec3 camPos, vec3 camTarget, float fPersp)
{
    // Calculate camera's "orthonormal basis", i.e. its transform matrix components
    vec3 camForward = normalize(camTarget - camPos);
    vec3 camRight = normalize(cross(vec3(0.0, 1.0, 0.0), camForward));
    vec3 camUp = normalize(cross(camForward, camRight));
     
    vec3 vDir = normalize(pos.x * camRight + pos.y * camUp + camForward * fPersp);
 
    return vDir;
}


void main() {
  vec2 pos = (v_texCoord - vec2(0.5,0.5))*2.0;
  pos.x *= u_dims.x/u_dims.y;


    // vec3 camPos = vec3(0.0, 10.0+sin(u_time*0.01)*10.2, -1.0/* -1.0+sin(u_time*0.001)*5.2 */);
    // vec3 camPos = vec3(0.0, ((sin(u_time*0.001)+1.0)*0.5)*5.0, -0.4);
    vec3 camPos = vec3(0.0, 0.35, 0.3);
    float ang = 0.0;//u_time*0.003;
    camPos.xz = mat2(cos(ang), -sin(ang),
             sin(ang), cos(ang)) * camPos.xz;


    // vec3 camTarget = vec3(0.0, 0.0, 10.0);// vec3(0,0,0);
    vec3 camTarget = vec3(0.0);// vec3(0,0,0);
    
    vec3 rayDir = getCameraRayDir(pos, camPos, camTarget, ((sin(u_time*0.001)+1.0)*0.5+0.1)/* 2.0 */);
    
    vec3 camForward = normalize(camTarget - camPos);
    vec3 col = render(camPos, camForward, rayDir);
    
    outColor = vec4(col, 1); // Output to screen



//   // signed distance for scene
//   float sd = sdf(pos);
//   // compute signed distance to a colour
//   vec3 col = shade(sd);

//   // float circ = length(pos) < 0.3? 1.0 : 0.0;
//   // outColor = vec4(1,circ,0,1);
  
//   outColor = vec4(col, 1.0);

    // outColor = vec4(pos.x+.5,pos.y+.5,0.0,1.0);
    // outColor = length(pos) > 0.3? vec4(1.0) : vec4(0.0,0.0,0.0,1.0);
    
}