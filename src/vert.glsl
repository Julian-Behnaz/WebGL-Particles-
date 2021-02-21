#version 300 es
 
in vec4 a_position;
in vec4 a_normal;
in float a_data;

uniform float u_time;

// out highp vec2 v_texCoord;

void main() {
  // v_texCoord = vec2((a_position.x+1.0)/2.0, (a_position.y+1.0)/2.0);
  float thickness = 0.1;
  gl_Position = a_position + a_normal * (thickness*0.5) + vec4(0, a_data, 0, 0);
  gl_Position.x *= 2.0;
  gl_Position.x -= 1.0;
  gl_Position.y *= 2.0;
  gl_Position.y -= 1.0;
}