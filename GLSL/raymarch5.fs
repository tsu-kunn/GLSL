#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform vec3 u_camera;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

const float sphereSize = 2.; // 球の半径

const float angle = 60.0;
const float fov = angle * 0.5 * PI / 180.0;

const vec3 lightDir = vec3(0.0,  0.0, 10.0); // ライトの位置
const vec3 Intensity = vec3(0.9, 0.9, 0.9);
const vec3 Direction = vec3(0.0, 0.0, -1.0);     // 正規化方向
float exponent = 30.0;   // 減衰指数
float cutoff = 12.0;

const vec3 La = vec3(0.3, 0.3, 0.3);      // アンビエント・ライト強度
const vec3 Ld = vec3(1.0, 1.0, 1.0);        // ディフューズ・ライト強度
const vec3 Ls = vec3(0.6, 0.6, 0.6);        // スペキュラ・ライト強度

const vec3 Kd = vec3 (0.2, 0.5, 0.9);     // ディフューズ反射率
const vec3 Ka = vec3(0.9 * 0.3, 0.5 * 0.3, 0.3 * 0.3);      // アンビエント反射率
const vec3 Ks = vec3(0.95, 0.95, 0.95);      // スペキュラ反射率
const float shininess = 100.0;                 // スペキュラの輝き係数

float distanceSphere(vec3 p) {
    return (length(p) - sphereSize);
}

float distanceFunc(vec3 p) {
    float d0 = distanceSphere(p + vec3(3.0, -3.0, 0.0));
    float d1 = distanceSphere(p + vec3(-3.0, -3.0, 0.0));
    float d2 = distanceSphere(p + vec3(3.0, 3.0, 0.0));
    float d3 = distanceSphere(p + vec3(-3.0, 3.0, 0.0));

    return min(min(min(d0, d1), d2), d3);
}

float distanceColor(vec3 p) {
    float d0 = distanceSphere(p + vec3(3.0, -3.0, 0.0));
    float d1 = distanceSphere(p + vec3(-3.0, -3.0, 0.0));
    float d2 = distanceSphere(p + vec3(3.0, 3.0, 0.0));
    float d3 = distanceSphere(p + vec3(-3.0, 3.0, 0.0));

    float min0 = min(min(min(d0, d1), d2), d3);

    float sphereNo = 0.0;
    sphereNo = mix(0.0, 1.0, step(d0, min0));
    sphereNo = mix(sphereNo, 2.0, step(d1, min0));
    sphereNo = mix(sphereNo, 3.0, step(d2, min0));
    sphereNo = mix(sphereNo, 4.0, step(d3, min0));

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

vec3 diffuseShading(vec3 s, vec3 n) {
    // ディフューズシェーディング方程式
    return Ld * Kd * max(dot(s, n), 0.0);
}

vec3 phongShading(vec3 ray, vec3 s, vec3 n) {
    // フォンシェーディング方程式
    vec3 v = normalize(-ray);
    vec3 r = reflect(-s, n);
    vec3 ambient = La * Ka;
    float sDotN = clamp(dot(s, n), 0.01, 1.0);
    vec3 diffuse = Ld * Kd * sDotN;
    // vec3 spec = Ls * Ks * pow(max(dot(r, v), 0.0), shininess);

    // 中間ベクトル使用
    vec3 h = normalize(v + s);
    vec3 spec = Ls * Ks * pow(max(dot(h, n), 0.0), shininess);

    return ambient + diffuse + spec;
}

vec3 spotLight(vec3 lp, vec3 ray, vec3 n) {
    vec3 s = normalize(vec3(lp - ray));
    float a = acos(dot(-s, Direction)); // angle
    float co = radians(clamp(cutoff, 0.0, 90.0)); // cutoff
    vec3 amb = Intensity * Ka; // ambient

    if (a < co) {
        float spotFactor = pow(dot(-s, Direction), exponent);
        // vec3 v = normalize(vec3(-ray));
        // vec3 h = normalize(v + s);

        // return amb + spotFactor * Intensity * 
        //     (Kd * max(dot(s, n), 0.0) + 
        //      Ks * pow(max(dot(h, n), 0.0), shininess));
        return spotFactor * Intensity;
    }

    return amb;
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // camera
    vec3 cPos = vec3(u_camera.x - 0.0, u_camera.y + 0.0, u_camera.z + 10.0);

    // ray
    vec3 ray = normalize(vec3(sin(fov) * pos.x, sin(fov) * pos.y, -cos(fov)));

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
    lp.x = cos(u_time) * 3.0;
    lp.y = sin(u_time) * 1.5;
    lp = normalize(lp);

    // hit check
    vec3 color = vec3(0.5);

    if (abs(dist) < 0.001) {
        vec3 normal = getNormal(rPos);

        // light
        vec3 s = normalize(vec3(lp - ray));
        vec3 L = vec3(0.0);
        float sphereNo = distanceColor(rPos);

        color = spotLight(lp, ray, normal);

        if (sphereNo == 1.0 || sphereNo == 4.0) {
            // ディフューズ
            L = diffuseShading(s, normal);
        } else if (sphereNo == 2.0 || sphereNo == 3.0) {
            // フォン
            L = phongShading(ray, s, normal);
        }
        color *= L;
    }

    gl_FragColor = vec4(color, 1.0);
}
