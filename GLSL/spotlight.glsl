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
    v_position = u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;
    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;

// light
const vec4 LightPosition = vec4(0.0, -5.0,  0.0, 1.0);
const vec3 Intensity = vec3(0.5, 0.5, 0.5);
const vec3 Direction = vec3(0.3, 1.0, 0.0);     // 正規化方向
float exponent = 0.6;   // 減衰指数
float cutoff = 45.0;

// material
const vec3 Ka = vec3(0.5, 0.5, 0.5);      // アンビエント反射率
const vec3 Kd = vec3(0.3, 0.3, 0.3);     // ディフューズ反射率
const vec3 Ks = vec3(0.4, 0.4, 0.4);      // スペキュラ反射率
const float shininess = 6.0;              // スペキュラの輝き係数

vec3 ads_spotlight(vec4 lightPos) {
    vec3 s = normalize(vec3(lightPos - v_position));
    float a = acos(dot(-s, Direction)); // angle
    float co = radians(clamp(cutoff, 0.0, 90.0)); // cutoff
    vec3 amb = Intensity  * Ka; // ambient

    if (a < co) {
        float spotFactor = pow(dot(-s, Direction), exponent);
        vec3 v = normalize(vec3(-v_position));
        vec3 h = normalize(v + s);

        return amb + spotFactor * Intensity * 
            (Kd * max(dot(s, v_normal.xyz), 0.0) + 
             Ks * pow(max(dot(h, v_normal.xyz), 0.0), shininess));
    }

    return amb;
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    vec4 lp = LightPosition;
    lp.x += cur.x * 2.0;
    lp.y += cur.y * 2.0;
    vec3 color = ads_spotlight(lp);

    gl_FragColor = vec4(color, 1.0) * v_color;
}

#endif
