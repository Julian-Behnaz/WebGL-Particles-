#version 300 es

in vec4 a_position;
uniform sampler2D u_texture;
out highp vec2 v_texCoord;

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
  gl_Position = a_position * 0.002;
  gl_Position.w = 1.0;

  // 0 - 255
    int width= 255;
    int height= 255;
    int yIndex= gl_InstanceID/width;
    int xIndex= gl_InstanceID-yIndex*width;
    float x= float(xIndex)/float(width);
    float y= float(yIndex)/float(height);


  vec4 posOffsetEncoded = texture(u_texture, vec2(x,y)); // rgba
  vec2 posOffset = vec2(decode(posOffsetEncoded.rg), decode(posOffsetEncoded.ba));
  // vec2 posOffset= vec2(0.0,0.0);
//   gl_Position.x += float(gl_InstanceID) * 0.1;
  gl_Position.x += posOffset.x;
  gl_Position.y += posOffset.y;

  v_texCoord = vec2((a_position.x+1.0)/2.0, (a_position.y+1.0)/2.0);
}