precision highp float;

uniform sampler2D tex;
varying vec2 v_texcoord;

vec3 remap(vec3 col, vec3 min, vec3 max) {
    return (col - min) / (max - min);
}

void main() {
    vec4 col = texture2D(tex, v_texcoord);
    vec3 c = col.rgb;
    c = pow(c, vec3(2.2));
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(luma), c, 1.3);
    c = pow(c, vec3(1.0 / 2.2));
    gl_FragColor = vec4(c, col.a);
}