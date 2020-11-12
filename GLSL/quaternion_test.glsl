#version 300 es

#include "GLSL/quaternion.glsl"

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

out vec4 FragColor;

float sdBox(vec3 p, vec3 b) {
  p = abs(p) - b;
  return length(max(p, 0.0)) + min(max(p.x, max(p.y, p.z)), 0.0);
}

float map(vec3 p) {
  Quaternion q1 = qaxisAngle(vec3(1.0, 1.0, 0.0), 0.84);
  Quaternion q2 = qaxisAngle(vec3(0.5, 0.2, 1.0), 4.32);
  Quaternion q = qslerp(q1, q2, u_mouse.x);
  p = qrotate(p, q);

  return sdBox(p, vec3(1.0, 1.5, 2.0));
}

vec3 calcNormal(vec3 p) {
  float d = 0.01;
  return normalize(vec3(
    map(p + vec3(d, 0.0, 0.0)) - map(p - vec3(d, 0.0, 0.0)),
    map(p + vec3(0.0, d, 0.0)) - map(p - vec3(0.0, d, 0.0)),
    map(p + vec3(0.0, 0.0, d)) - map(p - vec3(0.0, 0.0, d))
  ));
}

vec3 raymarch(vec3 ro, vec3 rd) {
  vec3 p = ro;
  for (int i = 0; i < 128; i++) {
    float d = map(p);
    p += d * rd;
    if (d < 0.01) {
        vec3 n = calcNormal(p);
        return n * 0.5 + 0.5;
    }
  }
}

void main(void) {
  vec2 st = (2.0 * gl_FragCoord.xy - u_resolution) / min(u_resolution.x, u_resolution.y);

  vec3 ro = vec3(0.0, 0.0, 10.0);
  vec3 ta = vec3(0.0);
  vec3 z = normalize(ta - ro);
  vec3 up = vec3(0.0, 1.0, 0.0);
  vec3 x = normalize(cross(z, up));
  vec3 y = normalize(cross(x, z));
  vec3 rd = normalize(x * st.x + y * st.y + z * 1.5);


  vec3 c = raymarch(ro, rd);

  FragColor = vec4(c, 1.0);
}
