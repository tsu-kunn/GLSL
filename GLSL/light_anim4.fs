#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

vec3 hsv(float h, float s, float v){
    vec4 t = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + t.xyz) * 6.0 - vec3(t.w));
    return v * mix(vec3(t.x), clamp(p - vec3(t.x), 0.0, 1.0), s);
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // 光源
    float l = 1.5 / length(cur - pos) + sin(abs(cur.x)) * 0.15;

    // 円
    float t = 0.02 / abs(0.5 - length(pos));

    // 花模様
    float r = 0.1 / abs((sin((atan(pos.y, pos.x) + u_time * 0.5) * 7.0)) - length(pos));

    vec3  color = hsv((l + u_time) * 0.0175, 1.0, r);

    gl_FragColor = vec4(vec3(l * t * r) * color, 1.0);
}
