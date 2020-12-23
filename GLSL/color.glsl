#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_position;
varying vec4 v_normal;
varying vec2 v_texcoord;
varying vec4 v_color;

uniform mat4 u_projectionMatrix;
uniform mat4 u_modelViewMatrix;
uniform mat4 u_normalMatrix;
uniform vec2 u_resolution;
uniform float u_time;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

#if defined(VERTEX)

attribute vec4 a_position;
attribute vec4 a_normal;
attribute vec2 a_texcoord;
attribute vec4 a_color;

void main(void) {
    v_position = u_projectionMatrix * u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;
    gl_Position = v_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

vec3 rgb2hsb(vec3 c) {
    vec4 K = vec4(0.0, (-1.0 / 3.0), (2.0 / 3.0), -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), (d / (q.x + e)), q.x);
}

vec3 hsb2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return (c.z * mix(vec3(1.0), rgb, c.y));
}

void main() {
    // vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 pos = gl_FragCoord.xy / u_resolution;
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // Use polar coordinates instead of cartesian
    vec2 center = vec2(0.5) - pos;
    float angle = atan(center.y, center.x);
    float radius = length(center) * 2.0;

    // vec3 c = hsb2rgb(vec3(pos.x, 1.0, pos.y));
    // vec3 c = rgb2hsb(vec3(pos.x, 1.0, pos.y));
    vec3 c = hsb2rgb(vec3((angle / PI2) + 0.5 + u_time, radius, 1.0)); // u_time加算で回転

    gl_FragColor = vec4(c, 1.0) * v_color;
}

#endif
