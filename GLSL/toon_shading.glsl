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
const vec4 LightPosition = vec4(10.0,  10.0,  20.0, 1.0);
const vec3 Intensity = vec3(0.5, 0.5, 0.5);

// material
const vec3 Ka = vec3(0.5, 0.5, 0.5);     // アンビエント反射率
const vec3 Kd = vec3(0.3, 0.3, 0.3);     // ディフューズ反射率

const float level = 4.0;
const float scaleFactor = 1.0 / level;

// アンビエントとディフューズだけを計算する簡易バージョン
// TODO: 輪郭線強調
//       簡易的なやり方としてカリング設定を逆にして輪郭を強調させる方法があるが、glsl-canvasではできない
//         ⇒http://nullpot.blog.fc2.com/blog-entry-91.html
vec3 toonShading(vec4 lightPos) {
    vec3 s = normalize(lightPos.xyz - v_position.xyz);
    float n = max(0.0, dot(s, v_normal.xyz));
    // vec3 diffuse = Kd * floor(n * level) * scaleFactor;
    vec3 diffuse = Kd * ceil(n * level) * scaleFactor;  // 少し明るくするバージョン

    return (Intensity * (Ka + diffuse));
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    vec4 lp = LightPosition;
    lp.x += sin(u_time) * 10.0;
    lp.z += cos(u_time) * 10.0;
    
    vec3 color = toonShading(lp);

    gl_FragColor = vec4(color, 1.0) *  v_color;
}

#endif
