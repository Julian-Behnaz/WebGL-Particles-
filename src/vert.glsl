#version 300 es
 
// an attribute is an input (in) to a vertex shader.
// It will receive data from a buffer
in vec4 a_position;
// in vec4 a_color;
// in vec2 a_translation;

uniform float u_time;

out highp vec2 v_texCoord;

// all shaders have a main function
void main() {
 
  // x' = x*cos(theta) - y*sin(theta)
  // y' = y*cos(theta) + x*sin(theta)

  // | cos(theta)  -sin(theta) 0 |
  // | sin(theta)  cos(theta)  0 |
  // | 0               0       1 |

  // | 1  0  0 |
  // | 0  1  0 |
  // | 0  0  1 |

// mat2 rotate2d(float _angle){
//     return mat3(cos(_angle),-sin(_angle), 0,
//                 sin(_angle),cos(_angle), 0,
//                   0,          0,      1);
// }

    // float _angle = (u_time + float(gl_InstanceID) * 1000.0) /10000.0;//3.14159265359 / time;
    // mat3 mat = mat3(  cos(_angle),      -sin(_angle),     0.0,
    //                   sin(_angle),      cos(_angle),      0.0,
    //                   a_translation.x,  a_translation.y,  1.0);



  // float slowTime = u_time/1000.0; 
  // // vColor = a_color;
  // vColor = vec4(((sin(slowTime + float(gl_InstanceID)+0.5))+1.0)/2.0 * 0.1,
  //               ((sin(slowTime + float(gl_InstanceID)+3.0))+1.0)/2.0,
  //               ((sin(slowTime + float(gl_InstanceID)+5.0))+1.0)/2.0
  //               ,1);// vec4((u_time + (sin(float(gl_InstanceID))+1.0)/2.0, 1.0),0,0,1);

  // gl_Position is a special variable a vertex shader
  // is responsible for setting
  // gl_Position = vec4(mat * a_position.xyw, 1.0);
  v_texCoord = vec2((a_position.x+1.0)/2.0, (a_position.y+1.0)/2.0);
  gl_Position = a_position;
}