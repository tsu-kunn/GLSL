#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_position;
varying vec4 v_normal;
varying vec2 v_texcoord;
varying vec4 v_color;

varying vec3 L;

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

// light
const vec4 LightPosition0 = vec4(-5.577,  5.577,  0.577, 1.0);
const vec4 LightPosition1 = vec4(-10.000, -10.000, -10.000, 1.0);
const vec4 LightPosition2 = vec4( 10.000,  10.000,  10.000, 1.0);

const vec3 Intensity0 = vec3(0.5, 0.0, 0.0);
const vec3 Intensity1 = vec3(0.0, 0.5, 0.0);
const vec3 Intensity2 = vec3(0.0, 0.0, 0.5);

// material
const vec3 Ka = vec3(0.5, 0.5, 0.5);      // アンビエント反射率
const vec3 Kd = vec3(0.3, 0.3, 0.3);     // ディフューズ反射率
const vec3 Ks = vec3(0.4, 0.4, 0.4);      // スペキュラ反射率
const float shininess = 6.0;              // スペキュラの輝き係数

vec3 ads_shading(vec4 eyePos, vec3 norm, vec4 lightPos, vec3 Intensity) {
    vec3 s = normalize(vec3(lightPos - eyePos));
    vec3 v = normalize(vec3(-eyePos));
    vec3 I = Intensity;
#if 0
    // 通常計算
    vec3 r = reflect(-s, norm);

    return (I * (Ka + Kd * max(dot(s, norm), 0.0) + Ks * pow(max(dot(r, v), 0.0), shininess)));
#else
    // 中間ベクトル使用
    vec3 n = normalize(norm);
    vec3 h = normalize(v + s);

    return (I * (Ka + Kd * max(dot(s, norm), 0.0) + Ks * pow(max(dot(h, n), 0.0), shininess)));
#endif
}

void main(void) {
    v_position = u_projectionMatrix * u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;

    // ライティングごとに法線と位置を視点座標に変換
    vec4 eyePos = u_modelViewMatrix * vec4(a_position.xyz, 1.0);

    // WebGL1.0では配列の初期化をサポートしていないので展開
    L = vec3(0.0);
    L += ads_shading(eyePos, v_normal.xyz, LightPosition0, Intensity0);
    L += ads_shading(eyePos, v_normal.xyz, LightPosition1, Intensity1);
    L += ads_shading(eyePos, v_normal.xyz, LightPosition2, Intensity2);

    gl_Position = v_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    gl_FragColor = vec4(L, 1.0) * v_color;
}

#endif
