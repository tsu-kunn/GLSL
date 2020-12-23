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
    // MEMO: モデルを球などポリゴンが多いものにする
    float m = 0.5 * sin(u_time * 2.0 + a_position.x * 2.0);
    v_position = vec4(a_position.x, a_position.y + m, a_position.z, a_position.w);
    v_position = u_projectionMatrix * u_modelViewMatrix * v_position;

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

    // ライティング処理
    vec3 lp = vec3(-0.577, 0.577, 0.577);
    lp.x += sin(u_time);
    lp.z += cos(u_time);

    vec3 l = normalize(lp);
    float diff = clamp(dot(v_normal.xyz, l), 0.1, 1.0);

    gl_FragColor = vec4((v_color.rgb * diff), v_color.a);
}

#endif
