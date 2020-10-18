#version 300 es

in vec4 a_position;
uniform sampler2D u_texture;

void main() {
  gl_Position = a_position * 0.001;
  gl_Position.w = 1.0;

  // 0 - 255

  float x = float(gl_InstanceID/255)/255.0;
  float y = float(gl_InstanceID%255)/255.0;

  vec4 posOffsetEncoded = texture(u_texture, vec2(x,y)); // rgba
  vec2 posOffset = vec2(((posOffsetEncoded.r+posOffsetEncoded.g)*0.5-0.5)*2.0,
                         ((posOffsetEncoded.b+posOffsetEncoded.a)*0.5-0.5)*2.0);
//   gl_Position.x += float(gl_InstanceID) * 0.1;
  gl_Position.x += posOffset.x;
  gl_Position.y += posOffset.y;
}