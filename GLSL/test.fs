#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

uniform vec2 u_mouse;

out vec4 FlagColor;

float rand(float x) {
    return fract(sin(x) * 10000.0);
}


bool inCircle(vec2 pos, vec2 offset, float size) {
    float len = length(pos - offset);
    return (len < size ? true : false);
}  

bool inRect(vec2 pos, vec2 offset, float size) {
    vec2 q = (pos - offset) / size;
    float m = 0.5 * sin(u_time * 3.0 + q.x * 2.0);

    return (abs(q.x) < 1.0 && abs(q.y + m) < 1.0 ? true: false);
}

bool inEllipse(vec2 pos, vec2 offset, vec2 prop, float size) {
    float q = length((pos - offset) / prop);
    return (q < size ? true : false);
}

float circle(vec2 pos, float r) {
    return abs(length(pos) - r) ;
}

float line(vec2 pos, vec2 a, vec2 b) {
    vec2 pa = pos - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void main(void) {
    vec3 color = vec3(1.0, 1.0, 1.0);
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    if (inCircle(pos, vec2(0.0, 0.0), 0.6)) {
        color *= vec3(1.0, 0.0, 0.0);
    }

    if (inRect(pos, vec2(0.5, -0.5), 0.25)) {
        color *= vec3(0.0, 0.0, 1.0);
    }

    if (inEllipse(pos, vec2(-0.5, -0.5), vec2(rand(u_time), 1.0), 0.2)) {
        color *= vec3(0.0, 1.0, 0.0);
    }

    float s = sin(u_time);
    float c = cos(u_time);
    mat2 rot = mat2(c, s, -s, c);
    color = mix(color, vec3(0.0, 1.0, 0.0), 1.0 - smoothstep(0.01, 0.015, line(pos, vec2(-1.0, -1.0), vec2(1.0, 1.0))));
    color = mix(color, vec3(0.0, 1.0, 0.0), 1.0 - smoothstep(0.01, 0.015, line(pos * rot, vec2(0.5, -0.5), vec2(-0.5, 0.5))));

    vec2 m = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    float at;
    at = clamp(mod(u_time, 3.0) - 1.0, 0.0, 3.0);
    at = pow(sin(at * radians(90.0)), 0.3);
    color = mix(color, vec3(0.5, 0.0, 0.5), 1.0 - smoothstep(0.01, 0.015, circle(pos - vec2(m.x, m.y), 0.35 * at)));

    FlagColor = vec4(color, 1.0);
}
