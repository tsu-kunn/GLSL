
#extension GL_OES_standard_derivatives : enable

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

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

#if 1
    const float lineW = 0.03;
    const float scale = 10.0;
    bvec2 toDiscard = greaterThan(fract(v_texcoord * scale), vec2(lineW));

    if (all(toDiscard)) {
        discard;
    }

    gl_FragColor = v_color;
#else
    const float lw = 0.03;
    const vec3 lc = vec3(1.0, 1.0, 1.0);
    const vec3 gc = vec3(0.5, 0.5, 0.5);
    const float div = 20.0;
    float divx = fract(div * v_texcoord.x);
    float divy = fract(div * v_texcoord.y);
    float lx = step(lw, divx);
    float ly = step(lw, divy);
    float hx = step(divx, 1.0 - lw);
    float hy = step(divy, 1.0 - lw);

    float l = lx * ly * hx * hy;
    gl_FragColor = vec4(smoothstep(lc.r, gc.r, l),
                        smoothstep(lc.g, gc.g, l),
                        smoothstep(lc.b, gc.b, l),
                        v_color.a);
#endif
}

#endif
