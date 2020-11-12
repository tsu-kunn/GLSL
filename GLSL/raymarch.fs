#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform vec3 u_camera;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

const float sphereSize = 1.0; // 球の半径
const vec3 lightDir = vec3(-0.577, 0.577, 0.577); // ライトの位置

const float angle = 60.0;
const float fov = angle * 0.5 * PI / 180.0;

// リピート表示
vec3 trans(vec3 p) {
    return (mod(p, 4.0) - 2.0);
}

vec3 rotate(vec3 p, float angle, vec3 axis){
    vec3 n = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float r = 1.0 - c;
    mat3 m = mat3( // ロドリゲスの回転公式
        n.x * n.x * r + c      , n.y * n.x * r - n.z * s, n.z * n.x * r + n.y * s,
        n.x * n.y * r + n.z * s, n.y * n.y * r + c      , n.z * n.y * r - n.x * s,
        n.x * n.z * r - n.y * s, n.y * n.z * r + n.x * s, n.z * n.z * r + c
    );
    return m * p;
}

float smoothMin(float d1, float d2, float k) {
    float h = exp(-k * d1) + exp(-k * d2);
    return (-log(h) / k);
}

float distanceTorus(vec3 p) {
    // vec2 t = vec2(0.75, 0.25);
    // vec2 r = vec2(length(p.xz) - t.x, p.y);
    vec2 t = vec2(1.5, 0.25);
    vec2 r = vec2(length(p.xy) - t.x, p.z);
    return (length(r) - t.y);
}

float distanceFloor(vec3 p) {
    return (dot(p, vec3(0.0, 1.0, 0.0)) + 1.0);
}

float distanceSphere(vec3 p) {
    return (length(trans(p)) - sphereSize);
    // return (length(p) - sphereSize);
}

float distanceBox(vec3 p) {
    // 箱(vec3: 箱の大きさ, 0.05: 角の丸み)
    // return (length(max(abs(trans(p)) - vec3(0.5, 0.25, 0.5), 0.0)) - 0.05);
    return (length(max(abs(p) - vec3(2.0, 0.1, 0.5), 0.0)) - 0.1);
}

// r.x: 円柱の太さ(半径)
// r.y: 円柱の長さ
float distanceCylinder(vec3 p, vec2 r) {
    vec2 d = abs(vec2(length(p.xy), p.z)) - r;
    return (clamp(d.x, d.y, 0.0) + length(max(d, 0.0)) - 0.1);
}

float distanceFunc(vec3 p) {
    vec3 q = rotate(p, radians(u_time * 20.0), vec3(1.0, 0.5, 0.0));
    float d1 = distanceTorus(q);
    float d2 = distanceFloor(p);
    float d3 = distanceBox(q);
    // float d4 = distanceSphere(p);
    // float d5 = distanceCylinder(q, vec2(0.75, 0.25));

    // return min(d1, d2);
    return min(min(d1, d2), d3);

    // return min(d1, d3);         // 重なり合った表示
    // return max(d1, d3);         // 重なり合う部分のみ表示
    // return max(-d1, d3);        // 重なる部分を排他表示(マイナスにした方)

    // return smoothMin(d1, d3, 8.0);
    // return smoothMin(smoothMin(d1, d3, 16.0), d5, 16.0);
}

vec3 getNormal(vec3 p) {
    const float d = 0.0001;
    return normalize(vec3(
        distanceFunc(p + vec3(  d, 0.0, 0.0)) - distanceFunc(p + vec3( -d, 0.0, 0.0)),
        distanceFunc(p + vec3(0.0,   d, 0.0)) - distanceFunc(p + vec3(0.0,  -d, 0.0)),
        distanceFunc(p + vec3(0.0, 0.0,   d)) - distanceFunc(p + vec3(0.0, 0.0,  -d))
    ));
}

float genShadow(vec3 ro, vec3 rd) {
    float h = 0.0;
    float c = 0.001;
    float r = 1.0;
    float shadow = 0.5;

    for (float t = 0.0; t < 32.0; t++) {
        h = distanceFunc(ro + rd * c);
        if (h < 0.001) {
            return shadow;
        }
        r = min(r, h * 16.0 / c);
        c += h;
    }
    return 1.0 - shadow + r * shadow;
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // camera
    vec3 cPos = vec3(u_camera.x - 3.0, u_camera.y + 4.0, u_camera.z + 4.0);

    // ray
#if 0
    vec3 ray = normalize(vec3(sin(fov) * pos.x, sin(fov) * pos.y, -cos(fov)));
#else
    const vec3 cDir = vec3(0.577, -0.577, -0.577);
    const vec3 cUp  = vec3(0.577, 0.577, -0.577);

    vec3 cSide = cross(cDir, cUp);
    float targetDepth = 1.0;
    vec3 ray = normalize(cSide * pos.x + cUp * pos.y + cDir * targetDepth);
#endif

    // marching loop
    float dist = 0.0;   // レイとオブジェクト間の最短距離
    float rLen = 0.0;   // レイに継ぎ足す長さ
    vec3  rPos = cPos;  // レイの先端位置

    for (int i = 0; i < 64; i++) {
        dist = distanceFunc(rPos);
        if (dist < 0.001) break;
        rLen += dist;
        rPos = cPos + ray * rLen;
    }

    // light offset
    vec3 light = normalize(lightDir + vec3(sin(u_time), 0.0, 0.0));

    // hit check
    vec3 color;
    float shadow = 1.0;
    if (abs(dist) < 0.001) {
        vec3 normal = getNormal(rPos);

        // light
        vec3 hl = normalize(light - ray);
        float diff = clamp(dot(light, normal), 0.1, 1.0);
        float spec = pow(clamp(dot(hl, normal), 0.0, 1.0), 50.0);

        // shadow
        shadow = genShadow(rPos + normal * 0.001, light);

        // UV
        float u = 1.0 - floor(mod(rPos.x , 2.0));
        float v = 1.0 - floor(mod(rPos.z , 2.0));
        if ((u == 1.0 && v < 1.0) || (u < 1.0 && v == 1.0)) {
            diff *= 0.7;
        }

        color = vec3(1.0, 1.0, 1.0) * diff + vec3(spec);
    } else {
        color = vec3(0.0);
    }
    gl_FragColor = vec4(color * max(0.5, shadow), 1.0);
}
