#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

out vec4 FlagColor;

void main(void) {
    vec2 p = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y); // 正規化
    vec3 destColor = vec3(1.0, 0.3, 0.7);

    float f = 0.0;
    for (float i = 0.0; i < 10.0; i++) {
        float s = sin(u_time + i * 0.628318) * 0.5; // 0.628318=円周率の1/5
        float c = cos(u_time + i * 0.628318) * 0.5;
        f += 0.0025 / abs(length(p + vec2(c, s)) - 0.5);
    }

    FlagColor = vec4(vec3(destColor * f), 1.0);
}
