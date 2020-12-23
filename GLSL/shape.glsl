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

float rect(vec2 pos, float b, float l, float t, float r) {
    vec2 bl, tr;
    bl = step(vec2(l, b), pos);
    tr = step(vec2(r, t), 1.0 - pos);
    return (bl.x * bl.y * tr.x * tr.y);
}

void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution;
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    vec3 color;
    float c;
    color = vec3(rect(pos, 0.1, 0.1, 0.1, 0.88));
    color += vec3(rect(pos, 0.1, 0.88, 0.1, 0.1));
    color += vec3(rect(pos, 0.1, 0.1, 0.89, 0.1));
    color += vec3(rect(pos, 0.89, 0.1, 0.1, 0.1));

    c = rect(pos, 0.7, 0.11, 0.1, 0.6);
    color += vec3(c, 0.0, 0.0);
    color += vec3(rect(pos, 0.69, 0.10, 0.3, 0.6));
    color += vec3(rect(pos, 0.1, 0.40, 0.1, 0.58));
    color += vec3(rect(pos, 0.79, 0.10, 0.2, 0.1));

    pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    float d = length(abs(pos) - 0.3);
    // color += vec3(fract(d * 10.0));
    color += vec3(smoothstep(0.3, 0.4, d) * smoothstep(0.6, 0.5, d));

    gl_FragColor = vec4(color, 1.0) * v_color;
}

#endif
