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

vec2 moveTile(vec2 st, float zoom) {
    st *= zoom;

#if 0
    st.x += step(1.0, mod(st.y, 2.0)) * (0.5 * u_time);
    if (mod(st.y, 2.0) < 1.0) {
        st.x -= 1.0 * (0.5 * u_time);
    }
#else
    float time = u_time * 0.5;
    float move = fract(time) * 2.0;

    if (fract(time) > 0.5) {
        if (fract(st.y * 0.5) > 0.5) {
            st.x += move;
        } else {
            st.x -= move;
        }
    } else {
        if (fract(st.x * 0.5) > 0.5) {
            st.y += move;
        } else {
            st.y -= move;
        }
    }
#endif

    return fract(st);
}

float box(vec2 st, vec2 size){
    size = vec2(0.5) - size * 0.5;

    vec2 uv = smoothstep(size, size + vec2(1e-4), st);
    uv *= smoothstep(size, size + vec2(1e-4), vec2(1.0) - st);

    return (uv.x * uv.y);
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    pos = moveTile(pos, 5.0);

    vec3 color = vec3(box(pos, vec2(0.9)));
    // vec3 color = vec3(pos, 0.0);

    gl_FragColor = vec4(color, 1.0);
}

#endif
