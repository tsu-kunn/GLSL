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
uniform sampler2D u_texture_0;

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // Get texture color
    // vec4 tcolor = texture2D(u_texture_0, v_texcoord);

    // Convert mosaic
    // float scale = 10.0 ; // 大きくするとモザイクのサイズが大きくなる
    float scale = 10.0 * abs(sin(u_time / 4.0));
    vec2 vUV = v_texcoord;

    vUV.x = floor(vUV.x * u_resolution.x / scale) / (u_resolution.x / scale) + (scale / 2.0) / u_resolution.x;
    vUV.y = floor(vUV.y * u_resolution.y / scale) / (u_resolution.y / scale) + (scale / 2.0) / u_resolution.y;

    // Get texture color
    // vec4 mcolor = texture2D(u_texture_0, vUV);
    vec4 mcolor = texture2D(u_texture_0, vUV);

    float ratio = abs(sin(u_time / 2.0));
    // gl_FragColor = mix(tcolor, mcolor, ratio) * v_color;
    gl_FragColor = mcolor * v_color;
}

#endif
