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

const float PI = 3.14159265;
const float PI2 = 6.28318531;

#if defined(VERTEX)

attribute vec4 a_position;
attribute vec4 a_normal;
attribute vec2 a_texcoord;
attribute vec4 a_color;

// light
const vec4 LightPosition = vec4(-0.577, 0.577,  0.577, 1.0);
const vec3 Intensity = vec3(0.5, 0.5, 0.5);

// fog
const float fogMax = 10.0; // 30.0
const float fogMin = 1.0;
const vec3 fogColor = vec3(0.18, 0.2, 0.25);    // 背景色にすると効果的

// material
const vec3 Ka = vec3(0.9, 0.5, 0.3);     // アンビエント反射率
const vec3 Kd = vec3(2.7, 1.5, 0.9);     // ディフューズ反射率
const vec3 Ks = vec3(0.4, 0.4, 0.4);     // スペキュラ反射率
const float shininess = 6.0;              // スペキュラの輝き係数

vec3 ads_shading(vec4 eyePos, vec4 lightPos, vec4 normal) {
    vec3 s = normalize(lightPos.xyz - eyePos.xyz);
    vec3 v = normalize(vec3(-v_position));
    vec3 h = normalize(v + s);

    vec3 ambient = Ka * Intensity;
    vec3 diffuse = Intensity * Kd * max(0.0, dot(s, normal.xyz));
    vec3 spec = Intensity * Ks * pow(max(0.0, dot(h, normal.xyz)), shininess);

    return (ambient + diffuse + spec);
}

void main(void) {
    v_position = u_projectionMatrix * u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;

    vec4 pos = u_modelViewMatrix * a_position;
    float dist = length(pos.xyz);
    float fogFactor = (fogMax - dist) / (fogMax - fogMin);
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    vec4 lp = LightPosition;
    lp.x += sin(u_time) * 10.0;
    lp.z += cos(u_time) * 10.0;
    
    vec3 color = ads_shading(pos, lp, v_normal);
    L = mix(fogColor, color, fogFactor);

    gl_Position = v_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    gl_FragColor = vec4(L, 1.0) *  v_color;
}

#endif
