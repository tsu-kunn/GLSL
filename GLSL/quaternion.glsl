// クォータニオン関数
// https://qiita.com/aa_debdeb/items/c34a3088b2d8d3731813

#ifdef GL_ES
precision mediump float;
#endif

#define Quaternion vec4

// struct Quaternion {
//     float x;
//     float y;
//     float z;
//     float w;
// };

// // クォータニオンの和
// Quaternion qadd(Quaternion q1, Quaternion q2) {
//     return Quaternion(q1.x + q2.x, q1.y + q2.y, q1.z + q2.z, q1.w + q2.w);
// }

// // クォータニオンの差
// Quaternion qsub(Quaternion q1, Quaternion q2) {
//     return Quaternion(q1.x - q2.x, q1.y - q2.y, q1.z - q2.z, q1.w - q2.w);
// }

// クォータニオンの積(実数)
Quaternion qmul(Quaternion q, float f) {
    return Quaternion(f * q.x, f * q.y, f * q.z, f * q.w);
}

// クォータニオンの積(クォータニオン)
Quaternion qmul(Quaternion q1, Quaternion q2) {
    return Quaternion(
         q1.w * q2.x - q1.z * q2.y + q1.y * q2.z + q1.x * q2.w,
         q1.z * q2.x + q1.w * q2.y - q1.x * q2.z + q1.y * q2.w,
        -q1.y * q2.x + q1.x * q2.y + q1.w * q2.z + q1.z * q2.w,
        -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z + q1.w * q2.w
    );
}

// // クォータニオンの積(内積)
// float qdot(Quaternion q1, Quaternion q2) {
//     return (q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w);
// }

// 共役クォータニオン
Quaternion qconjugate(Quaternion q) {
    return Quaternion(-q.x, -q.y, -q.z, q.w);
}

// クォータニオンのノルム
// ※ノルムが1のクォータニオンは回転を表す
float qnorm(Quaternion q) {
    return sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
}

// 恒等クォータニオン
// ※無回転を表す
Quaternion qidentity() {
    return Quaternion(0.0, 0.0, 0.0, 1.0);
}

// 逆クォータニオン
Quaternion qinverse(Quaternion q) {
    Quaternion c = qconjugate(q);
    float n = qnorm(q);
    return qmul(c, (1.0 / n));
}

// 任意軸の回転を表すクォータニオン
Quaternion qaxisAngle(vec3 axis, float radian) {
    vec3 naxis = normalize(axis);
    float h = 0.5 * radian; // Θ/2
    float s = sin(h);
    return Quaternion(naxis.x * s, naxis.y * s, naxis.z * s, cos(h));
}

// クォータニオンによるベクトルの回転
vec3 qrotate(vec3 v, Quaternion q) {
    Quaternion vq = Quaternion(v.x, v.y, v.z, 0.0); // vをクォータニオンとみなす
    Quaternion cq = qconjugate(q);
    Quaternion mq = qmul(qmul(q, vq), cq);
    return vec3(mq.x, mq.y, mq.z);
}

// クォータニオンによる球面線形補間
// ※t = 0 < t < 1
Quaternion qslerp(Quaternion q1, Quaternion q2, float t) {
    float r = acos(dot(q1, q2));
    float is = 1.0 / sin(r);
    return (qmul(q1, sin((1.0 - t) * r) * is) +
            qmul(q2, sin(t * r) * is));
}
