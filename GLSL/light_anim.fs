#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

out vec4 FlagColor;

void main(void) {
    vec2 p = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y); // 正規化
    vec3 destColor = vec3(0.0);

    for (float i = 0.0; i < 5.0; i++) {
        float j = i + 1.0;
        vec2 q = p + vec2(cos(u_time * j), sin(u_time * j)) * 0.5;
        destColor += 0.03 / length(q);
    }
    FlagColor = vec4(destColor, 1.0);
}
