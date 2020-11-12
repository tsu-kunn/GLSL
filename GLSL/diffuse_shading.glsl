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

vec4 LightPosition = vec4(-0.577, 0.577, 0.577, 1.0);
vec3 Kd = vec3 (0.3, 0.3, 0.3);     // ディフューズ反射率
vec3 Ld = vec3(2.0, 3.0, 5.0);          // 光源の強度

void main(void) {
    v_position = u_projectionMatrix * u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;

    // move light dir
    vec4 lp = LightPosition;
    lp.x = LightPosition.x + sin(u_time) * 10.0;
    lp.z = LightPosition.z + cos(u_time) * 10.0;

    // 法線と位置を視点座標に変換
    vec4 eyeCoords = u_modelViewMatrix * vec4(a_position.xyz, 1.0);
    vec3 s = normalize(vec3(lp - eyeCoords));

    // ディフューズシェーディング方程式
    L = Ld * Kd * max(dot(s, v_normal.xyz), 0.0);

    gl_Position = v_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;
uniform sampler2D u_texture_0;
// uniform vec2 u_textureResolution;

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // Get texture color
    vec4 tcolor = texture2D(u_texture_0, v_texcoord);

    gl_FragColor = vec4(L, 1.0) * v_color;
}

#endif
