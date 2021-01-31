#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform vec3 u_camera;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

const vec3 lightDir = vec3(-0.577, 0.577, 0.577); // ライトの位置


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
    vec2 t = vec2(1.5, 0.25);
    vec2 r = vec2(length(p.xy) - t.x, p.z);
    return (length(r) - t.y);
}

float distanceFloor(vec3 p) {
    return (dot(p, vec3(0.0, 1.0, 0.25)) + 1.0);
}

float distanceSphere(vec3 p, float s) {
    // s: 球の半径
    return (length(p) - s);
}

float distanceBox(vec3 p, vec3 r, float c) {
    // 箱(r: 箱の大きさ, c: 角の丸み)
    return (length(max(abs(p) - r, 0.0)) - c);
}

// r.x: 円柱の太さ(半径)
// r.y: 円柱の長さ
float distanceCylinder(vec3 p, vec2 r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - r;
    return (clamp(d.x, d.y, 0.0) + length(max(d, 0.0)) - 0.1);
}

float distanceFunc(vec3 p) {
    vec3 q1 = rotate(p, radians(u_time * 50.0), vec3(0.0, 1.0, 0.0));
    vec3 q2 = rotate(p + vec3(0.0, -0.0, 0.0), radians(u_time * 50.0), vec3(1.0, 0.0, -1.0));

    float s = sin(u_time * 0.5);
    float c = cos(u_time * 0.5);
    float mv = s * 0.5;

    mat3 rotX = mat3(1.0, 0.0, 0.0,
                     0.0,   c,   s,
                     0.0,  -s,   c);

    mat3 rotY = mat3(  c, 1.0,  -s,
                     0.0, 1.0, 0.0,
                       s, 0.0,   c);

    mat3 rotZ = mat3(  c,   s, 0.0,
                      -s,   c, 0.0,
                     0.0, 0.0, 1.0);

    float d0 = distanceFloor(p + vec3(0.0, 1.0, 0.0));
    float d1 = distanceBox(p + vec3(0.0, 0.0 + mv, 0.0), vec3(1.6, 0.1, 1.5), 0.05);
    float d2 = distanceBox(p + vec3(0.0, -3.0 - mv, 0.0), vec3(1.6, 0.1, 1.5), 0.05);
    float d3 = distanceBox(p + vec3(-1.5 - mv, -1.5, 0.0), vec3(0.1, 1.5, 1.5), 0.05);
    float d4 = distanceBox(p + vec3(1.5 + mv, -1.5, 0.0), vec3(0.1, 1.5, 1.5), 0.05);
    float d5 = distanceSphere(p + vec3(0.0, -1.5, 0.0), 1.0);

    float min0 = min(d0, d5);
    float min1 = min(min(min(d1, d2), d3), d4);
    float dst = smoothMin(min0, min1, 8.0);

    return dst;
}

float distanceColor(vec3 p) {
    float sphereNo = 0.0;

    return sphereNo;
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
        r = min(r, h * 16.0 / c);   // 16.0: ぼかし係数
        c += h;
    }
    return 1.0 - shadow + r * shadow;
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // camera
    vec3 cPos = vec3(u_camera.x - 0.0, u_camera.y + 4.0, u_camera.z + 10.0);

    // ray
    const vec3 cDir = vec3(0.0, -0.3, -1.0);
    const vec3 cUp  = vec3(0.0, 1.0, 0.0);

    vec3 cSide = cross(cDir, cUp);
    float targetDepth = 3.0;
    vec3 ray = normalize(cSide * pos.x + cUp * pos.y + cDir * targetDepth);

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
    vec3 lp = lightDir;
    lp.x = cos(u_time) * 1.0;
    lp.z = sin(u_time) * 1.0;
    lp = normalize(lp);

    // hit check
    vec3 color = vec3(1.0);
    float shadow = 1.0;

    if (abs(dist) < 0.001) {
        vec3 normal = getNormal(rPos);

        // light
        vec3 hl = normalize(lp - ray);
        float diff = clamp(dot(lp, normal), 0.1, 1.0);
        float spec = pow(clamp(dot(hl, normal), 0.0, 1.0), 50.0);

        // shadow
        // TODO: 影の重なりに対応(重なった部分は影なしで計算されている)
        shadow = genShadow(rPos + normal * 0.001, lp);

        // UV or color
        float sphereNo = distanceColor(rPos);
        if (sphereNo > 0.0) {
            color = mix(color, vec3(0.1, 0.3, 0.7), step(1.0, sphereNo));
            color = mix(color, vec3(0.7, 0.2, 0.1), step(2.0, sphereNo));
            color = mix(color, vec3(0.3, 0.7, 0.3), step(3.0, sphereNo));
        } else {
            float u = 1.0 - floor(mod(rPos.x , 2.0));
            float v = 1.0 - floor(mod(rPos.z , 2.0));
            if ((u == 1.0 && v < 1.0) || (u < 1.0 && v == 1.0)) {
                diff *= 0.7;
            }
        }

        color = color * diff + vec3(spec);
    }

    gl_FragColor = vec4(color * max(0.5, shadow), 1.0);
}
