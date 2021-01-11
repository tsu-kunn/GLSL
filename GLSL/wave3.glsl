#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

vec3 hsb2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return (c.z * mix(vec3(1.0), rgb, c.y));
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    vec3 color = vec3(0.8);

    // 四角
    vec2 q = (pos - vec2(0.0, 0.0)) / 0.8;
 
    // はためき（本来は頂点シェーダーで頂点を動す）
    float m = 0.5 * sin(u_time * 3.0 + q.x * 2.0);

    if (abs(q.x) < 1.0 && abs(q.y + m) < 1.0) {
        // color = vec3(0.0, 0.0, 1.0);

        vec2 center = vec2(0.0) - pos;
        float angle = atan(center.y, center.x);
        float radius = length(center) * 1.5;

        color = hsb2rgb(vec3((angle / PI2) + 0.5, radius, 1.0));
    }

    gl_FragColor = vec4(color, 1.0);
}
