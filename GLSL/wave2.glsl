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

const float k = PI2 / 3.5;   // 波の波長
const float v = 0.5;         // 波の速度
const float A = 1.5;         // 波の振幅

void main(void) {
    // MEMO: モデルを球などポリゴンが多いものにする
    vec4 pos = a_position;

    // move y
    float s = k * (pos.x - v * u_time);
    pos.y += A * sin(s);

    // move nonrmal(これやらない方がきれい)
    vec4 n = a_normal;
    n.xy = normalize(vec2(-k * A * cos(s), 1.0));

    v_position = u_modelViewMatrix * pos;
    v_normal = u_normalMatrix * n;
    v_texcoord = a_texcoord;
    v_color = a_color;

    gl_Position = u_projectionMatrix * u_modelViewMatrix * pos;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

const vec3 LightPosition = vec3(-0.577, 0.577, 0.577);
const vec3 Intensity = vec3(0.5, 0.5, 0.5);

// material
const vec3 Ka = vec3(0.9, 0.5, 0.3);     // アンビエント反射率
const vec3 Kd = vec3(2.7, 1.5, 0.9);     // ディフューズ反射率
const vec3 Ks = vec3(0.4, 0.4, 0.4);     // スペキュラ反射率
const float shininess = 6.0;              // スペキュラの輝き係数

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // 法線チェック
    vec4 n = v_normal;
    if (!gl_FrontFacing) {
        n = -n;
    }

    vec3 lp = LightPosition;
    lp.x += sin(u_time);
    lp.z += cos(u_time);

    // シェーディング処理
#if 0
    vec3 l = normalize(lp);
    float diff = clamp(dot(v_normal.xyz, l), 0.1, 1.0);

    gl_FragColor = vec4((v_color.rgb * diff), v_color.a);
#else
    vec3 s = normalize(lp - v_position.xyz);
    vec3 v = normalize(vec3(-v_position.xyz));
    vec3 r = reflect(-s, n.xyz);
    float sDotN = max(dot(s, n.xyz), 0.0);
    vec3 diff = Intensity * Kd * sDotN;
    vec3 spec = vec3(0.0);

    if (sDotN > 0.0) {
        spec = Intensity * Ks * pow(max(dot(r, v), 0.0), shininess);
    }

    gl_FragColor = vec4((Ka * Intensity + diff + spec), 1.0) * v_color;
#endif
}

#endif
