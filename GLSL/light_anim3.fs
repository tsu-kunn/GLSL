#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

out vec4 FlagColor;

void main(void) {
    vec2 p = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y); // 正規化
    vec2 q = mod(p, 0.2) - 0.1;

    float s = sin(u_time);
    float c = cos(u_time);

    q *= mat2( c, s,
              -s, c);

//    float v = 0.0001 / (abs(q.y) * abs(q.x));
    float v = 0.08 / abs(q.y) * abs(q.x);
    float r = v * abs(sin(u_time * 6.0) + 1.5);
    float g = v * abs(sin(u_time * 4.5) + 1.5);
    float b = v * abs(sin(u_time * 3.0) + 1.5);

    FlagColor = vec4(r, g, b, 1.0);
}
