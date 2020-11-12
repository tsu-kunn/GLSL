
#extension GL_OES_standard_derivatives : enable

#ifdef GL_ES
precision mediump float;
#endif

// WebGL 2.0 or OpenGL 3.0以上なら以下の指定だけでよい
// flat out vec3 v_position;

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
    // モデル空間の頂点情報まで（偏微分にはこの値が必要）
    v_position = u_modelViewMatrix * a_position;

    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;

    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

vec3 LightPosition = vec3(-0.577, 0.577, 0.577);

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // スクリーン空間上での偏微分より傾きを計算
    vec3 dx = dFdx(v_position.xyz);
    vec3 dy = dFdy(v_position.xyz);
    vec3 n  = normalize(cross(normalize(dx), normalize(dy)));

    // 光源の位置
    vec3 lp = LightPosition;
    lp.x += sin(u_time);
    lp.z += cos(u_time);

    vec3 l = normalize(lp);
    float diff = clamp(dot(n, l), 0.1, 1.0);

    gl_FragColor = vec4((v_color.rgb * diff), v_color.a);
}

#endif
